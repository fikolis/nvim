-- Interactive Visual Pattern Coach, Vim Grammar Matrix & Per-Level Walkthrough UI
-- Works alongside lua/fikolis/learn_dojo.lua and lua/fikolis/learn_solutions.lua.

local M = {}

local NS_FLOAT = vim.api.nvim_create_namespace("learn_dojo_coach_float")
local NS_HUD = vim.api.nvim_create_namespace("learn_dojo_coach_hud")

M.enabled = true

local hud_win = nil
local hud_buf = nil
local hud_timer = nil

-- Track incremental chord state for live visual coaching
local chord = {
    count = "",
    seq = "",
    updated_at = 0,
}

function M.define_hl()
    vim.api.nvim_set_hl(0, "DojoCoachTitle", { fg = "#7aa2f7", bold = true })
    vim.api.nvim_set_hl(0, "DojoCoachSection", { fg = "#bb9af7", bold = true })
    vim.api.nvim_set_hl(0, "DojoCoachVerb", { fg = "#9ece6a", bold = true })
    vim.api.nvim_set_hl(0, "DojoCoachMod", { fg = "#7dcfff", bold = true })
    vim.api.nvim_set_hl(0, "DojoCoachObj", { fg = "#e0af68", bold = true })
    vim.api.nvim_set_hl(0, "DojoCoachKey", { fg = "#f7768e", bold = true })
    vim.api.nvim_set_hl(0, "DojoCoachOk", { fg = "#9ece6a", bold = true })
    vim.api.nvim_set_hl(0, "DojoCoachTip", { fg = "#e0af68", italic = true })
    vim.api.nvim_set_hl(0, "DojoCoachDim", { fg = "#565f89" })
    vim.api.nvim_set_hl(0, "DojoCoachText", { fg = "#c0caf5" })
    vim.api.nvim_set_hl(0, "DojoCoachBorder", { fg = "#7aa2f7" })
end

-- Reusable color-coded Vim pattern dictionary (used by :DojoHint cards)
-- Each token is { text, hl_group } where hl is one of:
--   "verb" (green), "mod" (cyan), "obj" (yellow), "key" (magenta)
M.PATTERNS = {
    ["ciw"] = {
        tokens = { { "c", "verb", "Change" }, { "i", "mod", "Inside" }, { "w", "obj", "Word" } },
        desc = "obrisi rec pod kursorom i udji u Insert mod",
    },
    ['ci"'] = {
        tokens = { { "c", "verb", "Change" }, { "i", "mod", "Inside" }, { '"', "obj", '" "' } },
        desc = 'obrisi sve unutar " " i udji u Insert mod',
    },
    ["ci'"] = {
        tokens = { { "c", "verb", "Change" }, { "i", "mod", "Inside" }, { "'", "obj", "' '" } },
        desc = "obrisi sve unutar ' ' i udji u Insert mod",
    },
    ["ct:"] = {
        tokens = { { "c", "verb", "Change" }, { "t", "mod", "Till" }, { ":", "obj", ":" } },
        desc = "obrisi sve od kursora DO dvotacke ':' i udji u Insert mod",
    },
    ['vi"'] = {
        tokens = { { "v", "verb", "Visual" }, { "i", "mod", "Inside" }, { '"', "obj", '" "' } },
        desc = 'selektuj sve unutar " " (bez samih navodnika)',
    },
    ["vi'"] = {
        tokens = { { "v", "verb", "Visual" }, { "i", "mod", "Inside" }, { "'", "obj", "' '" } },
        desc = "selektuj sve unutar ' ' (bez samih navodnika)",
    },
    ["viw"] = {
        tokens = { { "v", "verb", "Visual" }, { "i", "mod", "Inside" }, { "w", "obj", "Word" } },
        desc = "selektuj celu rec pod kursorom",
    },
    ['yi"'] = {
        tokens = { { "y", "verb", "Yank" }, { "i", "mod", "Inside" }, { '"', "obj", '" "' } },
        desc = 'kopiraj tekst unutar " " (bez samih navodnika)',
    },
    ["yiw"] = {
        tokens = { { "y", "verb", "Yank" }, { "i", "mod", "Inside" }, { "w", "obj", "Word" } },
        desc = "kopiraj celu rec pod kursorom",
    },
    ['di"'] = {
        tokens = { { "d", "verb", "Delete" }, { "i", "mod", "Inside" }, { '"', "obj", '" "' } },
        desc = 'obrisi sve unutar " " (navodnici ostaju)',
    },
    ["ysiw\""] = {
        tokens = { { "ys", "verb", "You Surround" }, { "i", "mod", "Inside" }, { "w", "obj", "Word" }, { '"', "obj", '"' } },
        desc = 'obavij rec pod kursorom u duple navodnike ("rec")',
    },
    ["ysiw'"] = {
        tokens = { { "ys", "verb", "You Surround" }, { "i", "mod", "Inside" }, { "w", "obj", "Word" }, { "'", "obj", "'" } },
        desc = "obavij rec pod kursorom u jednostruke navodnike ('rec')",
    },
    ["ys3w)"] = {
        tokens = { { "ys", "verb", "You Surround" }, { "3w", "mod", "3 reci" }, { ")", "obj", "( )" } },
        desc = "obavij 3 reci u zagrade bez dodatnih razmaka",
    },
    ["yss)"] = {
        tokens = { { "yss", "verb", "You Surround Line" }, { ")", "obj", "( )" } },
        desc = "obavij celu liniju u zagrade ( )",
    },
    ["cs'\""] = {
        tokens = { { "cs", "verb", "Change Surround" }, { "'", "mod", "staro '" }, { '"', "obj", 'novo "' } },
        desc = "promeni jednostruke navodnike ' ' u duple \" \"",
    },
    ["cs\"'"] = {
        tokens = { { "cs", "verb", "Change Surround" }, { '"', "mod", 'staro "' }, { "'", "obj", "novo '" } },
        desc = "promeni duple navodnike \" \" u jednostruke ' '",
    },
    ["cs)}"] = {
        tokens = { { "cs", "verb", "Change Surround" }, { ")", "mod", "staro ()" }, { "}", "obj", "novo {}" } },
        desc = "promeni oble zagrade ( ) u viticaste { }",
    },
    ["ds)"] = {
        tokens = { { "ds", "verb", "Delete Surround" }, { ")", "obj", "( )" } },
        desc = "obrisi okruzujuce zagrade ( ) — sadrzaj unutra ostaje!",
    },
    ['ds"'] = {
        tokens = { { "ds", "verb", "Delete Surround" }, { '"', "obj", '" "' } },
        desc = 'obrisi okruzujuce navodnike " " — sadrzaj unutra ostaje!',
    },
    ["<leader>p"] = {
        tokens = { { 'vi"', "key", 'Visual Inside "' }, { "<Space>p", "verb", "Void Paste" } },
        desc = "zalepi preko selekcije BEZ gubitka yanka (mozes lepiti 10x zaredom!)",
    },
    ["<leader>dd"] = {
        tokens = { { "<Space>dd", "verb", "Void Delete Line" } },
        desc = "obrisi celu liniju u crnu rupu — NE gazi ono sto si kopirao!",
    },
    ["<leader>y"] = {
        tokens = { { "<Space>y / Y", "verb", "System Clipboard" } },
        desc = "kopiraj u macOS/sistemski clipboard (radi Cmd+V van Neovima)",
    },
    ["<leader>s"] = {
        tokens = { { "<Space>s", "verb", "Search & Replace" } },
        desc = "zameni rec pod kursorom SVUDA u fajlu odjednom",
    },
    ["<leader>+"] = {
        tokens = { { "<broj>", "mod", "korak" }, { "<Space>+ / -", "verb", "Inc / Dec" } },
        desc = "povecaj/smanji broj pod kursorom (tmux-safe zamena za <C-a>/<C-x>)",
    },
    ["f5r7"] = {
        tokens = { { "f", "mod", "Find napred" }, { "5", "obj", "znak '5'" }, { "r", "verb", "Replace 1 znak" }, { "7", "obj", "'7'" } },
        desc = "skoci na '5' i zameni ga sa '7' bez ulaska u Insert mod!",
    },
    ["gcc"] = {
        tokens = { { "gc", "verb", "Comment" }, { "c", "mod", "cela linija" } },
        desc = "zakomentarisi ili otkomentarisi trenutnu liniju",
    },
    ["V2jgc"] = {
        tokens = { { "V", "verb", "Visual Line" }, { "2j", "mod", "2 linije dole" }, { "gc", "verb", "Comment" } },
        desc = "selektuj 3 linije i zakomentarisi/otkomentarisi ceo blok odjednom",
    },
    ["V+JK"] = {
        tokens = { { "V", "verb", "Visual Line" }, { "J / K", "key", "Pomeri dole / gore" } },
        desc = "selektuj 1 ili vise linija pa ih pomeraj gore/dole kao ceo blok",
    },
    ["V+indent"] = {
        tokens = { { "V", "verb", "Visual Line" }, { "> / <", "verb", "Uvuci / Izvuci" }, { ".", "key", "Ponovi" } },
        desc = "uvuci blok za 2 razmaka (YAML) — pa stisni '.' ako treba jos jednom!",
    },
    ["J"] = {
        tokens = { { "J", "verb", "Join Lines" } },
        desc = "spoji sledecu liniju sa trenutnom (kursor ostaje na mestu!)",
    },
    ["<C-c>"] = {
        tokens = { { "<C-c>", "key", "Brzi Esc" } },
        desc = "brzi izlaz iz Insert moda bez pomeranja ruke na Esc",
    },
    ["<C-d/u>"] = {
        tokens = { { "<C-d> / <C-u>", "key", "Pola strane dole/gore" }, { "/", "mod", "Search" }, { "n / N", "key", "Sledeci/Prethodni" } },
        desc = "centrirano skrolovanje i skakanje kroz pogotke pretrage (uvek zz)",
    },
    ["<leader>?"] = {
        tokens = { { "<Space>?", "key", "Keymap Search" }, { "<Space>wk", "key", "Which-Key" }, { "<Space>w?", "key", "Buffer Keys" } },
        desc = "otkrij bilo koju precicu u svom configu bez napustanja editora",
    },
    ["]f"] = {
        tokens = { { "]f / [f", "key", "Next / Prev Function" } },
        desc = "Treesitter skok direktno na sledecu ili prethodnu funkciju",
    },
    ["cif"] = {
        tokens = { { "c", "verb", "Change" }, { "i", "mod", "Inside" }, { "f", "obj", "Function" } },
        desc = "zameni CELO telo funkcije (potpis i end ostaju netaknuti!)",
    },
    ["daf"] = {
        tokens = { { "d", "verb", "Delete" }, { "a", "mod", "Around" }, { "f", "obj", "Function" } },
        desc = "obrisi CELU funkciju od 'local function' do 'end' u 1 potezu!",
    },
    ["vaf"] = {
        tokens = { { "v", "verb", "Visual" }, { "a", "mod", "Around" }, { "f", "obj", "Function" } },
        desc = "selektuj CELU funkciju (pa J/K za pomeranje ili <Space>f za format!)",
    },
    ["cia"] = {
        tokens = { { "c", "verb", "Change" }, { "i", "mod", "Inside" }, { "a", "obj", "Argument" } },
        desc = "promeni vrednost parametra/argumenta funkcije (Treesitter)",
    },
    ["daa"] = {
        tokens = { { "d", "verb", "Delete" }, { "a", "mod", "Around" }, { "a", "obj", "Argument" } },
        desc = "obrisi parametar/argument ZAJEDNO sa zarezom!",
    },
    ["picker"] = {
        tokens = { { "<Space>pf", "key", "Find Files" }, { "<C-p>", "key", "Git Files" }, { "<Space>pb", "key", "Buffers" }, { "<Space>vh", "key", "Help" } },
        desc = "munjevito otvaranje fajlova, bafera i dokumentacije (Snacks)",
    },
    ["grep"] = {
        tokens = { { "<Space>pws", "key", "Grep word" }, { "<Space>pWs", "key", "Grep WORD (sa crticama)" }, { "<Space>ps", "key", "Live Grep" } },
        desc = "pretrazi ceo projekat za rec pod kursorom ili proizvoljan tekst",
    },
    ["oil"] = {
        tokens = { { "-", "verb", "Oil Folder" }, { "<Enter>", "key", "Udji / Otvori" }, { "<C-o>", "key", "Nazad (Jumplist)" } },
        desc = "edituj foldere kao obican Vim bafer i vracaj se sa - ili <C-o>",
    },
    ["harpoon"] = {
        tokens = { { "<Space>a", "verb", "Add File" }, { "<C-e>", "key", "Menu" }, { "<C-j/k/h/l>", "key", "Skok 1-4" } },
        desc = "pinuj najvaznije fajlove i leti izmedju njih na 1 pritisak",
    },
    ["zen_undo"] = {
        tokens = { { "<Space>zz / zZ", "key", "Zen Mode" }, { "<Space>u", "verb", "Undotree" } },
        desc = "fokus mod bez ometanja i vizuelno stablo SVIH grana istorije izmena",
    },
    ["lsp_nav"] = {
        tokens = { { "K", "key", "Hover Doc" }, { "gd", "verb", "Go Definition" }, { "<Space>vrr", "key", "References" }, { "<C-o>", "key", "Nazad" } },
        desc = "LSP navigacija kroz kod — dokumentacija, definicija i sve upotrebe",
    },
    ["lsp_rename"] = {
        tokens = { { "<Space>vrn", "verb", "LSP Rename" }, { "<C-n>/<C-p>", "mod", "Listaj" }, { "<C-y>", "verb", "Potvrdi" }, { "<C-h>", "key", "Signature" } },
        desc = "inteligentno preimenovanje simbola + autocomplete (blink.cmp)",
    },
    ["cmp"] = {
        tokens = { { "<C-n>/<C-p>", "mod", "Sledeci/Prethodni" }, { "<C-y>", "verb", "Yes (Potvrdi)" } },
        desc = "izaberi K8s/Ansible LSP predlog iz autocomplete menija",
    },
    ["diag"] = {
        tokens = { { "]d / [d", "key", "Next/Prev Diag" }, { "<Space>vd", "key", "Float" }, { "<Space>qb/qs", "key", "Trouble" }, { "<Space>vca", "verb", "Code Action" } },
        desc = "skakanje na greske/upozorenja i brze LSP popravke",
    },
    ["format"] = {
        tokens = { { "vaf", "mod", "Visual Around Func" }, { "<Space>f", "verb", "Format (Conform)" } },
        desc = "automatski sredi uvlacenje i stil samo selektovanog dela ili celog fajla",
    },
    ["git"] = {
        tokens = { { "]h / [h", "key", "Next/Prev Hunk" }, { "<Space>ghp", "key", "Preview" }, { "<Space>ghr", "verb", "Reset Hunk" }, { "<Space>gl", "key", "Lazygit" } },
        desc = "pregledaj, vrati pojedinacne git izmene ili otvori Lazygit/Fugitive",
    },
    ["ai"] = {
        tokens = { { "<Space>ca/cg/co/cx", "key", "AI Float" }, { "<C-q>", "verb", "Sakrij (ziva sesija)" } },
        desc = "otvori AI terminal u floatu i sakrij ga bez gasenja sesije",
    },
}

local HL_MAP = {
    verb = "DojoCoachVerb",
    mod = "DojoCoachMod",
    obj = "DojoCoachObj",
    key = "DojoCoachKey",
    ok = "DojoCoachOk",
    dim = "DojoCoachDim",
    tip = "DojoCoachTip",
    title = "DojoCoachTitle",
    section = "DojoCoachSection",
    text = "DojoCoachText",
}

-- Helper to build styled lines with byte-accurate highlight spans
local function new_doc()
    return { lines = {}, spans = {} }
end

local function add_line(doc, chunks)
    local line_idx = #doc.lines
    local parts = {}
    local col = 0
    for _, ch in ipairs(chunks) do
        local text = ch[1]
        local hl = HL_MAP[ch[2]] or ch[2]
        parts[#parts + 1] = text
        if hl and #text > 0 then
            doc.spans[#doc.spans + 1] = { line_idx, col, col + #text, hl }
        end
        col = col + #text
    end
    doc.lines[#doc.lines + 1] = table.concat(parts)
end

local function apply_doc(buf, ns, doc)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, doc.lines)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for _, sp in ipairs(doc.spans) do
        vim.api.nvim_buf_set_extmark(buf, ns, sp[1], sp[2], {
            end_col = sp[3],
            hl_group = sp[4],
        })
    end
    vim.bo[buf].modifiable = false
end

local function close_hud()
    if hud_timer then
        hud_timer:stop()
        hud_timer:close()
        hud_timer = nil
    end
    if hud_win and vim.api.nvim_win_is_valid(hud_win) then
        pcall(vim.api.nvim_win_close, hud_win, true)
    end
    hud_win = nil
end

local function show_hud(doc, duration_ms)
    if not M.enabled then
        return
    end
    local win_w = vim.api.nvim_win_get_width(0)
    if win_w < 44 then
        return
    end

    if not hud_buf or not vim.api.nvim_buf_is_valid(hud_buf) then
        hud_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[hud_buf].bufhidden = "hide"
        vim.bo[hud_buf].buftype = "nofile"
        vim.bo[hud_buf].swapfile = false
    end

    apply_doc(hud_buf, NS_HUD, doc)

    local width = 0
    for _, l in ipairs(doc.lines) do
        width = math.max(width, vim.fn.strdisplaywidth(l))
    end
    width = math.min(math.max(width + 2, 24), math.max(24, win_w - 4))
    local height = #doc.lines

    local cfg = {
        relative = "win",
        win = vim.api.nvim_get_current_win(),
        anchor = "NE",
        row = 1,
        col = math.max(1, win_w - 2),
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        focusable = false,
        noautocmd = true,
        zindex = 60,
    }

    if hud_win and vim.api.nvim_win_is_valid(hud_win) then
        pcall(vim.api.nvim_win_set_config, hud_win, cfg)
    else
        local ok, win = pcall(vim.api.nvim_open_win, hud_buf, false, cfg)
        if ok then
            hud_win = win
            pcall(function()
                vim.wo[hud_win].winhl = "Normal:NormalFloat,FloatBorder:DojoCoachBorder"
                vim.wo[hud_win].winblend = 8
            end)
        end
    end

    if hud_timer then
        hud_timer:stop()
        hud_timer:close()
    end
    hud_timer = vim.uv.new_timer()
    hud_timer:start(
        duration_ms or 3200,
        0,
        vim.schedule_wrap(function()
            close_hud()
        end)
    )
end

-- Helper to render a single complete or pending pill in the HUD
local function hud_complete(parts, desc)
    local doc = new_doc()
    local line1 = { { " ", "text" } }
    for idx, p in ipairs(parts) do
        if idx > 1 then
            line1[#line1 + 1] = { " + ", "dim" }
        end
        line1[#line1 + 1] = { "[" .. p[1] .. "]", p[2] }
        if p[3] and p[3] ~= "" then
            line1[#line1 + 1] = { " " .. p[3], "text" }
        end
    end
    line1[#line1 + 1] = { "  ✓", "ok" }
    add_line(doc, line1)
    if desc and desc ~= "" then
        add_line(doc, { { " -> ", "dim" }, { desc, "tip" } })
    end
    show_hud(doc, 3600)
end

local function hud_pending(parts, next_hint)
    local doc = new_doc()
    local line1 = { { " ", "text" } }
    for idx, p in ipairs(parts) do
        if idx > 1 then
            line1[#line1 + 1] = { " + ", "dim" }
        end
        line1[#line1 + 1] = { "[" .. p[1] .. "]", p[2] }
        if p[3] and p[3] ~= "" then
            line1[#line1 + 1] = { " " .. p[3], "text" }
        end
    end
    line1[#line1 + 1] = { "  ...", "dim" }
    add_line(doc, line1)
    if next_hint and next_hint ~= "" then
        add_line(doc, { { " cekam: ", "dim" }, { next_hint, "text" } })
    end
    show_hud(doc, 2600)
end

-- Dictionaries for live grammar decoding
local VERBS = {
    c = { "Change", "obrisi i udji u Insert mod" },
    d = { "Delete", "obrisi" },
    y = { "Yank", "kopiraj" },
    v = { "Visual", "selektuj" },
}

local MODS = {
    i = { "Inside", "unutar" },
    a = { "Around", "zajedno sa okvirom" },
}

local OBJECTS = {
    w = { "Word", "rec" },
    W = { "WORD", "celu rec sa simbolima" },
    ['"'] = { '" "', 'duplih navodnika " "' },
    ["'"] = { "' '", "jednostrukih navodnika ' '" },
    ["`"] = { "` `", "backtick-ova" },
    ["("] = { "( )", "zagrada ( )" },
    [")"] = { "( )", "zagrada ( )" },
    ["{"] = { "{ }", "viticastih zagrada { }" },
    ["}"] = { "{ }", "viticastih zagrada { }" },
    ["["] = { "[ ]", "uglastih zagrada [ ]" },
    ["]"] = { "[ ]", "uglastih zagrada [ ]" },
    ["<"] = { "< >", "tagova/uglastih < >" },
    [">"] = { "< >", "tagova/uglastih < >" },
    p = { "Paragraph", "pasusa" },
    f = { "Function", "funkcije (Treesitter)" },
    a = { "Argument", "argumenta/parametra (Treesitter)" },
    t = { "Tag", "HTML/XML taga" },
}

local FIND_MODS = {
    f = { "Find", "ukljucujuci znak" },
    t = { "Till", "DO znaka" },
    F = { "Find nazad", "unazad do znaka" },
    T = { "Till nazad", "unazad ispred znaka" },
}

local function reset_chord()
    chord.count = ""
    chord.seq = ""
end

local function is_printable_single(tok)
    return #tok == 1 and tok:byte(1) >= 32 and tok:byte(1) <= 126
end

-- Called from learn_dojo.lua's vim.on_key when inside a Dojo buffer
function M.on_key(token, mode)
    if not M.enabled or not token or token == "" then
        return
    end

    local now = vim.uv.hrtime() / 1e6
    if now - chord.updated_at > 2500 then
        reset_chord()
    end
    chord.updated_at = now

    local m1 = (mode or ""):sub(1, 1)

    -- Insert mode: only coach completion/escape chords, never normal text typing
    if m1 == "i" or m1 == "R" then
        reset_chord()
        if token == "<c-c>" then
            hud_complete({ { "<C-c>", "key", "Brzi Esc" } }, "izlaz iz Insert moda!")
        elseif token == "<c-y>" then
            hud_complete({ { "<C-y>", "verb", "Yes" } }, "potvrdi autocomplete predlog (blink.cmp)")
        elseif token == "<c-n>" or token == "<c-p>" then
            hud_complete({ { token:upper(), "mod", "Autocomplete" } }, "listaj predloge pa potvrdi sa <C-y>")
        elseif token == "<c-h>" then
            hud_complete({ { "<C-h>", "key", "Signature Help" } }, "prikazi parametre funkcije")
        end
        return
    end

    if m1 == "c" or m1 == "t" then
        reset_chord()
        return
    end

    if token == "<esc>" or token == "<c-c>" then
        reset_chord()
        close_hud()
        return
    end

    -- Visual mode direct actions (J, K, >, <, gc, <space>p, <space>d, <space>y, <space>f)
    if m1 == "v" or m1 == "V" or m1 == "\22" then
        if chord.seq == "" or chord.seq == "v" then
            if token == "J" then
                reset_chord()
                hud_complete({ { "V", "verb", "Visual" }, { "J", "key", "Dole" } }, "pomeri selektovane linije dole")
                return
            elseif token == "K" then
                reset_chord()
                hud_complete({ { "V", "verb", "Visual" }, { "K", "key", "Gore" } }, "pomeri selektovane linije gore")
                return
            elseif token == ">" then
                reset_chord()
                hud_complete({ { "V", "verb", "Visual" }, { ">", "verb", "Indent" } }, "uvuci selekciju udesno (ponovi sa '.')")
                return
            elseif token == "<" then
                reset_chord()
                hud_complete({ { "V", "verb", "Visual" }, { "<", "verb", "Outdent" } }, "izvuci selekciju ulevo (ponovi sa '.')")
                return
            elseif token == "i" or token == "a" then
                chord.seq = "v" .. token
                hud_pending(
                    { { "v", "verb", "Visual" }, { token, "mod", MODS[token][1] } },
                    'w (word) | " | \' | ) | } | f (func) | a (arg)'
                )
                return
            elseif token == "g" or token == "<space>" then
                chord.seq = token
                return
            end
        elseif chord.seq == "vi" or chord.seq == "va" then
            local mod_k = chord.seq:sub(2, 2)
            local obj = OBJECTS[token]
            reset_chord()
            if obj then
                hud_complete(
                    { { "v", "verb", "Visual" }, { mod_k, "mod", MODS[mod_k][1] }, { token, "obj", obj[1] } },
                    "selektuj " .. MODS[mod_k][2] .. " " .. obj[2]
                )
            end
            return
        elseif chord.seq == "g" and token == "c" then
            reset_chord()
            hud_complete({ { "V + gc", "verb", "Toggle Comment" } }, "zakomentarisi / otkomentarisi ceo blok")
            return
        elseif chord.seq == "<space>" then
            reset_chord()
            if token == "p" then
                hud_complete({ { "<Space>p", "verb", "Void Paste" } }, "zalepi preko selekcije BEZ gubitka yanka!")
            elseif token == "d" then
                hud_complete({ { "<Space>d", "verb", "Void Delete" } }, "obrisi selekciju u crnu rupu (cuva yank!)")
            elseif token == "y" then
                hud_complete({ { "<Space>y", "verb", "Clipboard Yank" } }, "kopirano u sistemski clipboard!")
            elseif token == "f" then
                hud_complete({ { "<Space>f", "verb", "Format" } }, "formatiraj selektovani blok (Conform)")
            end
            return
        end
        reset_chord()
        return
    end

    -- Normal / Operator-pending mode
    -- 1. Leading numeric count (e.g. `2<Space>+`, `7<Space>+`)
    if chord.seq == "" and token:match("^[1-9]$") or (chord.count ~= "" and chord.seq == "" and token:match("^[0-9]$")) then
        chord.count = chord.count .. token
        if #chord.count > 3 then
            chord.count = chord.count:sub(-3)
        end
        return
    end

    -- 2. Single-key instant coaches when seq == ""
    if chord.seq == "" then
        if token == "V" then
            reset_chord()
            hud_pending({ { "V", "verb", "Visual Line" } }, "J/K (pomeri) | >/< (uvuci) | gc (komentar)")
            return
        elseif token == "." then
            reset_chord()
            hud_complete({ { ".", "key", "Dot Repeat" } }, "ponovi poslednju izmenu!")
            return
        elseif token == "J" then
            reset_chord()
            hud_complete({ { "J", "verb", "Join Lines" } }, "spoji liniju ispod bez pomeranja kursora")
            return
        elseif token == "<c-d>" or token == "<c-u>" then
            reset_chord()
            local dir = token == "<c-d>" and "dole" or "gore"
            hud_complete({ { token:upper(), "key", "Scroll + zz" } }, "pola strane " .. dir .. " (centrirano!)")
            return
        elseif token == "K" then
            reset_chord()
            hud_complete({ { "K", "key", "Hover Doc" } }, "LSP dokumentacija za simbol pod kursorom")
            return
        elseif token == "-" then
            reset_chord()
            hud_complete({ { "-", "verb", "Oil" } }, "otvori parent folder kao Vim bafer")
            return
        elseif VERBS[token] then
            chord.seq = token
            if token == "v" then
                hud_pending({ { "v", "verb", "Visual" } }, 'i (inside) | a (around) -> npr. vi" ili vaf')
            elseif token == "c" then
                hud_pending({ { "c", "verb", "Change" } }, 'i (inside) | a (around) | t (till) | s (surround)')
            elseif token == "d" then
                hud_pending({ { "d", "verb", "Delete" } }, 'i (inside) | a (around) | s (surround) | d (linija)')
            elseif token == "y" then
                hud_pending({ { "y", "verb", "Yank" } }, 'i (inside) | a (around) | s (surround) | y (linija)')
            end
            return
        elseif FIND_MODS[token] then
            chord.seq = token
            hud_pending({ { token, "mod", FIND_MODS[token][1] } }, "ukucaj znak na koji skaces (npr. 5 ili :)")
            return
        elseif token == "r" then
            chord.seq = "r"
            hud_pending({ { "r", "verb", "Replace 1 znak" } }, "ukucaj novi karakter")
            return
        elseif token == "g" or token == "]" or token == "[" or token == "<space>" then
            chord.seq = token
            return
        end
        reset_chord()
        return
    end

    -- 3. Multi-key state transitions
    local s = chord.seq
    local cnt = chord.count

    -- Leader chords
    if s == "<space>" then
        if token == "+" or token == "-" then
            reset_chord()
            local label = (cnt ~= "" and cnt or "1")
            local verb = token == "+" and "Povecaj" or "Smanji"
            hud_complete(
                { { (cnt ~= "" and cnt or "") .. "<Space>" .. token, "verb", verb .. " za " .. label } },
                "tmux-safe zamena za " .. (token == "+" and "<C-a>" or "<C-x>")
            )
            return
        elseif token == "s" then
            reset_chord()
            hud_complete({ { "<Space>s", "verb", "Search & Replace" } }, "zameni rec pod kursorom svuda u fajlu!")
            return
        elseif token == "f" then
            reset_chord()
            hud_complete({ { "<Space>f", "verb", "Format" } }, "formatiraj bafer (Conform)")
            return
        elseif token == "u" then
            reset_chord()
            hud_complete({ { "<Space>u", "verb", "Undotree" } }, "otvori stablo istorije izmena")
            return
        elseif token == "Y" then
            reset_chord()
            hud_complete({ { "<Space>Y", "verb", "Clipboard Line" } }, "kopiraj celu liniju u sistemski clipboard")
            return
        elseif token == "d" then
            chord.seq = "<space>d"
            hud_pending({ { "<Space>d", "verb", "Void Delete" } }, "d (cela linija) ili motion (npr. iw)")
            return
        elseif token == "v" or token == "g" or token == "p" or token == "q" then
            chord.seq = "<space>" .. token
            return
        end
        reset_chord()
        return
    elseif s == "<space>d" then
        reset_chord()
        if token == "d" then
            hud_complete({ { "<Space>dd", "verb", "Void Delete Line" } }, "linija obrisana u crnu rupu (tvoj yank je sacuvan!)")
        end
        return
    elseif s == "<space>vr" and token == "n" then
        reset_chord()
        hud_complete({ { "<Space>vrn", "verb", "LSP Rename" } }, "preimenuj simbol inteligentno svuda")
        return
    elseif s == "<space>v" and (token == "r" or token == "c" or token == "d") then
        if token == "d" then
            reset_chord()
            hud_complete({ { "<Space>vd", "key", "Diagnostic Float" } }, "prikazi detalje greske pod kursorom")
        else
            chord.seq = s .. token
        end
        return
    elseif s == "<space>vc" and token == "a" then
        reset_chord()
        hud_complete({ { "<Space>vca", "verb", "Code Action" } }, "ponudi brzu LSP popravku")
        return
    end

    -- Bracket jumps (`]f`, `[f`, `]d`, `[d`, `]h`, `[h`)
    if s == "]" or s == "[" then
        reset_chord()
        local dir = s == "]" and "Sledeca" or "Prethodna"
        if token == "f" then
            hud_complete({ { s .. "f", "key", dir .. " funkcija" } }, "Treesitter skok izmedju funkcija")
        elseif token == "d" then
            hud_complete({ { s .. "d", "key", dir .. " dijagnostika" } }, "skok na gresku / upozorenje")
        elseif token == "h" then
            hud_complete({ { s .. "h", "key", dir .. " Git izmena" } }, "skok izmedju Git hunk-ova")
        end
        return
    end

    -- `g` prefixes: `gd`, `gc` -> `gcc`
    if s == "g" then
        if token == "d" then
            reset_chord()
            hud_complete({ { "gd", "verb", "Go to Definition" } }, "skoci na definiciju (nazad sa <C-o>)")
            return
        elseif token == "c" then
            chord.seq = "gc"
            hud_pending({ { "gc", "verb", "Comment" } }, "c (ova linija) ili 2j (n linija dole)")
            return
        end
        reset_chord()
        return
    elseif s == "gc" then
        reset_chord()
        if token == "c" then
            hud_complete({ { "gcc", "verb", "Toggle Comment" } }, "zakomentarisi / otkomentarisi liniju")
        end
        return
    end

    -- Single-char find/replace completion: `f5`, `r7`
    if FIND_MODS[s] and is_printable_single(token) then
        reset_chord()
        hud_complete(
            { { s, "mod", FIND_MODS[s][1] }, { token, "obj", "'" .. token .. "'" } },
            "skok na '" .. token .. "' (ponovi sa ';' ili zameni znak sa 'r')"
        )
        return
    elseif s == "r" and is_printable_single(token) then
        reset_chord()
        hud_complete({ { "r", "verb", "Replace" }, { token, "obj", "'" .. token .. "'" } }, "zamenjen 1 karakter bez Insert moda!")
        return
    end

    -- Surround transitions: `ys`, `cs`, `ds`
    if (s == "y" or s == "c" or s == "d") and token == "s" then
        chord.seq = s .. "s"
        if chord.seq == "ys" then
            hud_pending({ { "ys", "verb", "You Surround" } }, 'i (inside) + w + "  |  s (cela linija) + )')
        elseif chord.seq == "cs" then
            hud_pending({ { "cs", "verb", "Change Surround" } }, "prvo STARI znak (npr. ' ili )), pa NOVI")
        elseif chord.seq == "ds" then
            hud_pending({ { "ds", "verb", "Delete Surround" } }, 'koji znak skidas? )  "  \'  }')
        end
        return
    elseif s == "ds" and is_printable_single(token) then
        reset_chord()
        local obj = OBJECTS[token]
        hud_complete(
            { { "ds", "verb", "Delete Surround" }, { token, "obj", obj and obj[1] or token } },
            "obrisi okruzujuce " .. (obj and obj[1] or token) .. " — tekst unutra ostaje!"
        )
        return
    elseif s == "cs" and is_printable_single(token) then
        chord.seq = "cs" .. token
        hud_pending({ { "cs", "verb", "Change Surround" }, { token, "mod", "staro " .. token } }, 'sad ukucaj NOVI znak (npr. " ili })')
        return
    elseif #s == 3 and s:sub(1, 2) == "cs" and is_printable_single(token) then
        local old_c = s:sub(3, 3)
        reset_chord()
        hud_complete(
            { { "cs", "verb", "Change Surround" }, { old_c, "mod", old_c }, { token, "obj", token } },
            "promeni okruzenje " .. old_c .. " u " .. token
        )
        return
    elseif s == "ys" then
        if token == "s" then
            chord.seq = "yss"
            hud_pending({ { "yss", "verb", "You Surround Line" } }, 'ukucaj znak okruzenja: )  "  }')
            return
        elseif token == "i" or token == "a" then
            chord.seq = "ys" .. token
            hud_pending({ { "ys", "verb", "You Surround" }, { token, "mod", MODS[token][1] } }, 'w (word) | " | )')
            return
        end
        reset_chord()
        return
    elseif s == "yss" and is_printable_single(token) then
        reset_chord()
        hud_complete({ { "yss", "verb", "You Surround Line" }, { token, "obj", token } }, "obavij celu liniju sa " .. token)
        return
    elseif (s == "ysi" or s == "ysa") and OBJECTS[token] then
        chord.seq = s .. token
        local mod_k = s:sub(3, 3)
        hud_pending(
            { { "ys", "verb", "You Surround" }, { mod_k, "mod", MODS[mod_k][1] }, { token, "obj", OBJECTS[token][1] } },
            'ukucaj cime obavijas: "  \'  )  }'
        )
        return
    elseif #s == 4 and (s:sub(1, 3) == "ysi" or s:sub(1, 3) == "ysa") and is_printable_single(token) then
        local mod_k = s:sub(3, 3)
        local obj_k = s:sub(4, 4)
        local obj = OBJECTS[obj_k]
        reset_chord()
        hud_complete(
            {
                { "ys", "verb", "You Surround" },
                { mod_k, "mod", MODS[mod_k][1] },
                { obj_k, "obj", obj and obj[1] or obj_k },
                { token, "obj", token },
            },
            "obavij " .. (obj and obj[2] or obj_k) .. " sa " .. token
        )
        return
    end

    -- Core Vim Grammar: [c/d/y/v] + [i/a] + [object]  OR  [c/d/y/v] + [t/f/T/F] + <char>
    if VERBS[s] then
        if MODS[token] then
            chord.seq = s .. token
            hud_pending(
                { { s, "verb", VERBS[s][1] }, { token, "mod", MODS[token][1] } },
                'w (word) | " | \' | ) | } | f (func) | a (arg)'
            )
            return
        elseif FIND_MODS[token] then
            chord.seq = s .. token
            hud_pending(
                { { s, "verb", VERBS[s][1] }, { token, "mod", FIND_MODS[token][1] } },
                "ukucaj granicni znak (npr. : ili ,)"
            )
            return
        elseif token == "w" or token == "W" then
            reset_chord()
            hud_complete({ { s, "verb", VERBS[s][1] }, { token, "obj", OBJECTS[token][1] } }, VERBS[s][2] .. " do kraja reci")
            return
        end
        reset_chord()
        return
    elseif #s == 2 and VERBS[s:sub(1, 1)] then
        local v_k = s:sub(1, 1)
        local m_k = s:sub(2, 2)
        reset_chord()
        if MODS[m_k] and OBJECTS[token] then
            local obj = OBJECTS[token]
            hud_complete(
                { { v_k, "verb", VERBS[v_k][1] }, { m_k, "mod", MODS[m_k][1] }, { token, "obj", obj[1] } },
                VERBS[v_k][2] .. " " .. MODS[m_k][2] .. " " .. obj[2]
            )
        elseif FIND_MODS[m_k] and is_printable_single(token) then
            hud_complete(
                { { v_k, "verb", VERBS[v_k][1] }, { m_k, "mod", FIND_MODS[m_k][1] }, { token, "obj", "'" .. token .. "'" } },
                VERBS[v_k][2] .. " " .. FIND_MODS[m_k][2] .. " '" .. token .. "'"
            )
        end
        return
    end

    reset_chord()
end

-- Open a centered, scrollable, color-coded floating card
local function open_card(title, doc, allow_grammar_jump)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].swapfile = false
    apply_doc(buf, NS_FLOAT, doc)

    local max_w = 0
    for _, l in ipairs(doc.lines) do
        max_w = math.max(max_w, vim.fn.strdisplaywidth(l))
    end
    local ui_w = vim.o.columns
    local ui_h = vim.o.lines - 2
    local width = math.min(math.max(max_w + 4, 62), math.max(40, ui_w - 6))
    local height = math.min(#doc.lines + 1, math.max(10, ui_h - 4))
    local row = math.max(0, math.floor((ui_h - height) / 2))
    local col = math.max(0, math.floor((ui_w - width) / 2))

    local ok, win = pcall(vim.api.nvim_open_win, buf, true, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = " " .. title .. " ",
        title_pos = "center",
    })
    if not ok then
        return nil
    end

    pcall(function()
        vim.wo[win].wrap = true
        vim.wo[win].linebreak = true
        vim.wo[win].cursorline = false
        vim.wo[win].winhl = "Normal:NormalFloat,FloatBorder:DojoCoachBorder,FloatTitle:DojoCoachTitle"
    end)

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end
    vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, silent = true })
    vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true, silent = true })
    vim.keymap.set("n", "<C-c>", close, { buffer = buf, nowait = true, silent = true })
    if allow_grammar_jump then
        vim.keymap.set("n", "g", function()
            close()
            M.show_grammar()
        end, { buffer = buf, nowait = true, silent = true })
    end
    return win, doc.lines
end

local function render_pattern(doc, pat_key)
    local p = type(pat_key) == "table" and pat_key or M.PATTERNS[pat_key]
    if not p then
        return
    end
    local chunks = { { "  ", "text" } }
    for idx, t in ipairs(p.tokens) do
        if idx > 1 then
            chunks[#chunks + 1] = { " + ", "dim" }
        end
        chunks[#chunks + 1] = { "[" .. t[1] .. "]", t[2] }
        if t[3] and t[3] ~= "" then
            chunks[#chunks + 1] = { " " .. t[3], "text" }
        end
    end
    add_line(doc, chunks)
    add_line(doc, { { "      -> ", "dim" }, { p.desc, "tip" } })
end

-- Show rich per-level visual patterns + step-by-step explained solution (:DojoHint / :DojoExplain)
function M.show_level(game_id, game_title, level_id, level_title)
    local ok, solutions = pcall(require, "fikolis.learn_solutions")
    if not ok then
        vim.notify("Nisam uspeo da ucitam learn_solutions: " .. tostring(solutions), vim.log.levels.ERROR)
        return nil
    end

    local game_sols = solutions[game_id] or {}
    local entry = game_sols[level_id]
    if not entry then
        vim.notify(string.format("Nema sacuvanog resenja za %s Nivo %02d.", tostring(game_id), tonumber(level_id) or 0), vim.log.levels.WARN)
        return nil
    end

    local doc = new_doc()
    add_line(doc, {
        { string.format(" NIVO %02d — %s ", level_id, level_title or ""), "title" },
        { "(" .. (game_title or game_id) .. ")", "dim" },
    })
    add_line(doc, { { " " .. string.rep("─", 72), "dim" } })

    -- Section 1: Visual Vim Patterns
    add_line(doc, { { " VIZUELNI OBRASCI  ", "section" }, { "([Glagol] ", "verb" }, { "+ [Opseg] ", "mod" }, { "+ [Objekat])", "obj" } })
    add_line(doc, { { "", "text" } })
    for _, pk in ipairs(entry.patterns or {}) do
        render_pattern(doc, pk)
    end

    -- Section 2: Step-by-step explained solution for THIS exact level
    add_line(doc, { { "", "text" } })
    add_line(doc, { { " RESENJE KORAK PO KORAK (kroz objasnjenje):", "section" } })
    add_line(doc, { { "", "text" } })
    for idx, step in ipairs(entry.steps or {}) do
        add_line(doc, {
            { string.format("  %d. ", idx), "ok" },
            { step, "text" },
        })
    end

    -- Section 3: Mental model takeaway
    if entry.tip and entry.tip ~= "" then
        add_line(doc, { { "", "text" } })
        add_line(doc, { { " ZAPAMTI OBRAZAC: ", "section" }, { entry.tip, "tip" } })
    end

    add_line(doc, { { "", "text" } })
    add_line(doc, { { " " .. string.rep("─", 72), "dim" } })
    add_line(doc, {
        { " [q / Esc]", "key" },
        { " Zatvori   |   ", "dim" },
        { "[g]", "key" },
        { " Cela Vim Gramatika   |   ", "dim" },
        { ":DojoCoach", "key" },
        { " Live HUD (" .. (M.enabled and "ON" or "OFF") .. ")", "dim" },
    })

    local title = string.format("Dojo Hint & Resenje — Nivo %02d", level_id)
    return open_card(title, doc, true)
end

-- Show the full visual Vim Language Matrix (:DojoGrammar)
function M.show_grammar()
    local doc = new_doc()
    add_line(doc, { { " VIM JEZIK — FORMULA KOJA POKRIVA 90% SVEGA U NEOVIMU", "title" } })
    add_line(doc, { { " " .. string.rep("─", 72), "dim" } })
    add_line(doc, {
        { "  Formula:  ", "text" },
        { "[BROJ?]", "key" },
        { " + ", "dim" },
        { "[GLAGOL]", "verb" },
        { " + ", "dim" },
        { "[OPSEG]", "mod" },
        { " + ", "dim" },
        { "[OBJEKAT]", "obj" },
    })
    add_line(doc, { { "", "text" } })

    add_line(doc, { { " 1. GLAGOLI (Sta radis?)", "section" } })
    add_line(doc, { { "    [c]", "verb" }, { " Change (obrisi + Insert)    ", "text" }, { "[d]", "verb" }, { " Delete (obrisi)        ", "text" }, { "[y]", "verb" }, { " Yank (kopiraj)", "text" } })
    add_line(doc, { { "    [v]", "verb" }, { " Visual (selektuj)           ", "text" }, { "[ys]", "verb" }, { " You Surround (dodaj)  ", "text" }, { "[cs]", "verb" }, { " Change Surround", "text" } })
    add_line(doc, { { "    [ds]", "verb" }, { " Delete Surround (skini)    ", "text" }, { "[gc]", "verb" }, { " Comment (komentar)    ", "text" }, { "[> / <]", "verb" }, { " Uvuci / Izvuci", "text" } })
    add_line(doc, { { "", "text" } })

    add_line(doc, { { " 2. OPSEG (Gde / koliko?)", "section" } })
    add_line(doc, { { "    [i]", "mod" }, { " Inside (samo UNUTRA — bez navodnika/zagrada)", "text" } })
    add_line(doc, { { "    [a]", "mod" }, { " Around (SA okvirom — ukljucuje navodnike, zagrade, zarez ili celu funkciju)", "text" } })
    add_line(doc, { { "    [t]", "mod" }, { " Till   (DO znaka, bez njega — npr. ct: brise do ':')", "text" } })
    add_line(doc, { { "    [f]", "mod" }, { " Find   (DO znaka, ukljucujuci njega — npr. f5 skace na '5')", "text" } })
    add_line(doc, { { "", "text" } })

    add_line(doc, { { " 3. OBJEKTI (Nad cim?)", "section" } })
    add_line(doc, { { "    [w]", "obj" }, { " Word   ", "text" }, { '["]', "obj" }, { ' " "   ', "text" }, { "[']", "obj" }, { " ' '   ", "text" }, { "[)]", "obj" }, { " ( )   ", "text" }, { "[}]", "obj" }, { " { }   ", "text" }, { "[]]", "obj" }, { " [ ]", "text" } })
    add_line(doc, { { "    [f]", "obj" }, { " Function (Treesitter)   ", "text" }, { "[a]", "obj" }, { " Argument (Treesitter)   ", "text" }, { "[p]", "obj" }, { " Paragraph", "text" } })
    add_line(doc, { { "", "text" } })

    add_line(doc, { { " 4. NAJCESCE KOMBINACIJE (citaj ih naglas kao recenice!)", "section" } })
    local examples = {
        { { { "v", "verb" }, { "i", "mod" }, { '"', "obj" } }, 'Visual Inside " "         -> selektuj sve unutar duplih navodnika' },
        { { { "c", "verb" }, { "i", "mod" }, { "'", "obj" } }, "Change Inside ' '         -> obrisi unutar ' ' i odmah kucaj novo" },
        { { { "y", "verb" }, { "i", "mod" }, { '"', "obj" } }, 'Yank Inside " "           -> kopiraj samo vrednost bez navodnika' },
        { { { "c", "verb" }, { "t", "mod" }, { ":", "obj" } }, "Change Till ':'           -> zameni kljuc do dvotacke (YAML/Ansible!)" },
        { { { "ys", "verb" }, { "i", "mod" }, { "w", "obj" }, { '"', "obj" } }, 'You Surround Inside Word "-> obavij rec u navodnike' },
        { { { "cs", "verb" }, { "'", "mod" }, { '"', "obj" } }, "Change Surround ' -> \"    -> zameni jednostruke navodnike duplim" },
        { { { "ds", "verb" }, { ")", "obj" } }, "Delete Surround )         -> skini zagrade ( ) oko teksta" },
        { { { "d", "verb" }, { "a", "mod" }, { "f", "obj" } }, "Delete Around Function    -> obrisi celu funkciju u 1 potezu" },
        { { { "d", "verb" }, { "a", "mod" }, { "a", "obj" } }, "Delete Around Argument    -> obrisi parametar ZAJEDNO sa zarezom" },
    }
    for _, ex in ipairs(examples) do
        local ch = { { "    ", "text" } }
        for _, t in ipairs(ex[1]) do
            ch[#ch + 1] = { t[1], t[2] }
        end
        local pad = math.max(1, 8 - #table.concat(vim.tbl_map(function(x) return x[1] end, ex[1])))
        ch[#ch + 1] = { string.rep(" ", pad) .. "= ", "dim" }
        ch[#ch + 1] = { ex[2], "text" }
        add_line(doc, ch)
    end

    add_line(doc, { { "", "text" } })
    add_line(doc, { { " 5. TVOJ CONFIG SUPER-MOCI (Leader = <Space>)", "section" } })
    add_line(doc, { { "    [vi\"<Space>p]", "key" }, { " Paste bez gubitka yanka     ", "text" }, { "[<Space>dd]", "key" }, { " Obrisi u crnu rupu (cuva yank)", "text" } })
    add_line(doc, { { "    [<Space>s]", "key" }, { "    Zameni rec svuda u fajlu    ", "text" }, { "[2<Space>+]", "key" }, { " Povecaj broj za +2 (tmux-safe!)", "text" } })
    add_line(doc, { { "    [V + J/K]", "key" }, { "     Pomeraj blok gore/dole      ", "text" }, { "[V + > .]", "key" }, { "   Uvuci blok (+ '.' ponovi!)", "text" } })

    add_line(doc, { { "", "text" } })
    add_line(doc, { { " " .. string.rep("─", 72), "dim" } })
    add_line(doc, { { " [q / Esc]", "key" }, { " Zatvori   |   ", "dim" }, { ":DojoHint", "key" }, { " Resenje za trenutni nivo   |   ", "dim" }, { ":DojoCoach", "key" }, { " Live HUD", "dim" } })

    return open_card("Vim Gramatika — Vizuelni Podsetnik", doc, false)
end

function M.toggle()
    M.enabled = not M.enabled
    if not M.enabled then
        close_hud()
    end
    vim.notify(
        string.format("Dojo Live Visual Coach: %s", M.enabled and "ON (prikazuje obrasce dok kucas)" or "OFF"),
        vim.log.levels.INFO
    )
end

M.close_hud = close_hud

return M
