-- Multi-game interactive Dojo checker (learning/learn_nvim.lua & learning/learn_nvim.yaml).
-- Code goals read the play region (between IGRAJ OVDE and OCEKIVANI).
-- Key goals use keymap hooks + vim.on_key's typed chord.
-- The buffer is `acwrite`, so :w saves to the player's JSON save slot without touching disk.
-- ExitPre auto-saves progress and restores disk text so quitting never dirties the repo.

local M = {}

local NS = vim.api.nvim_create_namespace("learn_dojo_marks")

local GAMES = {}
local GAMES_ORDER = { "core", "k8s", "ansible" }

local state = {
    player = "default",
    game = "core",
    players = {},
    actions = {},
    solved = {},
    harpoon_files = {},
    ai_counts = {},
    runs = 0,
    saved_lines = nil,
    saved_disk_sig = nil,
    announced = {},
    session = false,
    greeted = {},
    pausing = {},
    victory = {},
    armed = {},
    seen_fp = {},
}

local function disk_sig_for(buf)
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return nil
    end
    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" or vim.fn.filereadable(name) ~= 1 then
        return nil
    end
    local ok, lines = pcall(vim.fn.readfile, name)
    if not ok or type(lines) ~= "table" then
        return nil
    end
    return vim.fn.sha256(table.concat(lines, "\n"))
end

local function can_restore_saved_lines(buf)
    if type(state.saved_lines) ~= "table" or #state.saved_lines <= 10 then
        return false
    end
    local cur_sig = disk_sig_for(buf)
    if not cur_sig or not state.saved_disk_sig or state.saved_disk_sig ~= cur_sig then
        return false
    end
    return true
end

local function progress_path()
    if vim.g.learn_dojo_progress and vim.g.learn_dojo_progress ~= "" then
        return vim.g.learn_dojo_progress
    end
    return vim.fn.stdpath("data") .. "/learn_nvim_dojo.json"
end

local function clean_player_name(name)
    if type(name) ~= "string" then
        return nil
    end
    local trimmed = vim.trim(name)
    if trimmed == "" then
        return nil
    end
    return trimmed
end

local function count_solved(slot)
    local n = 0
    if type(slot) == "table" and type(slot.solved) == "table" then
        for _, v in pairs(slot.solved) do
            if v == true then
                n = n + 1
            end
        end
    end
    return n
end

local function make_empty_slot()
    return {
        actions = {},
        solved = {},
        harpoon_files = {},
        ai_counts = {},
        runs = 0,
        saved_at = os.date("%Y-%m-%d %H:%M"),
        saved_lines = nil,
        saved_disk_sig = nil,
    }
end

local function ensure_player_record(name)
    local key = clean_player_name(name) or "default"
    local rec = state.players[key]
    if type(rec) ~= "table" then
        rec = { games = {} }
        state.players[key] = rec
    elseif type(rec.games) ~= "table" then
        -- Migrate single-game player slot into games.core
        local legacy = {
            actions = type(rec.actions) == "table" and rec.actions or {},
            solved = type(rec.solved) == "table" and rec.solved or {},
            harpoon_files = type(rec.harpoon_files) == "table" and rec.harpoon_files or {},
            ai_counts = type(rec.ai_counts) == "table" and rec.ai_counts or {},
            runs = tonumber(rec.runs) or 0,
            saved_at = rec.saved_at or os.date("%Y-%m-%d %H:%M"),
            saved_lines = type(rec.saved_lines) == "table" and rec.saved_lines or nil,
        }
        rec = { games = { core = legacy } }
        state.players[key] = rec
    end
    return rec, key
end

local function get_player_game_slot(player_name, game_id)
    local rec = ensure_player_record(player_name)
    local gid = game_id or state.game or "core"
    if type(rec.games[gid]) ~= "table" then
        rec.games[gid] = make_empty_slot()
    end
    return rec.games[gid]
end

local function apply_slot(name, game_id)
    local gid = game_id or state.game or "core"
    local _, key = ensure_player_record(name)
    local slot = get_player_game_slot(key, gid)
    state.player = key
    state.game = gid
    state.actions = type(slot.actions) == "table" and vim.deepcopy(slot.actions) or {}
    state.solved = type(slot.solved) == "table" and vim.deepcopy(slot.solved) or {}
    state.harpoon_files = type(slot.harpoon_files) == "table" and vim.deepcopy(slot.harpoon_files) or {}
    state.ai_counts = type(slot.ai_counts) == "table" and vim.deepcopy(slot.ai_counts) or {}
    state.runs = tonumber(slot.runs) or 0
    state.saved_lines = (type(slot.saved_lines) == "table" and #slot.saved_lines > 10)
            and vim.deepcopy(slot.saved_lines)
        or nil
    state.saved_disk_sig = type(slot.saved_disk_sig) == "string" and slot.saved_disk_sig or nil
    state.announced = {}
    state.armed = {}
    state.seen_fp = {}
end

local function sync_active_slot(buf_lines, buf_sig)
    local rec, key = ensure_player_record(state.player)
    local gid = state.game or "core"
    state.player = key
    if buf_lines ~= nil then
        if buf_lines then
            state.saved_lines = vim.deepcopy(buf_lines)
            state.saved_disk_sig = buf_sig or state.saved_disk_sig
        else
            state.saved_lines = nil
            state.saved_disk_sig = nil
        end
    end
    rec.games[gid] = {
        actions = vim.deepcopy(state.actions),
        solved = vim.deepcopy(state.solved),
        harpoon_files = vim.deepcopy(state.harpoon_files),
        ai_counts = vim.deepcopy(state.ai_counts),
        runs = state.runs or 0,
        saved_at = os.date("%Y-%m-%d %H:%M"),
        saved_lines = state.saved_lines and vim.deepcopy(state.saved_lines) or nil,
        saved_disk_sig = state.saved_disk_sig,
    }
end

local function write_store()
    local path = progress_path()
    local dir = vim.fn.fnamemodify(path, ":h")
    if vim.fn.isdirectory(dir) == 0 then
        pcall(vim.fn.mkdir, dir, "p")
    end
    local payload = {
        active = state.player,
        active_game = state.game,
        players = state.players,
    }
    pcall(vim.fn.writefile, { vim.json.encode(payload) }, path)
end

local function save_progress(buf_lines, buf_sig)
    sync_active_slot(buf_lines, buf_sig)
    write_store()
end

local function load_progress()
    local ok, lines = pcall(vim.fn.readfile, progress_path())
    if not ok or type(lines) ~= "table" or #lines == 0 then
        state.players = {}
        apply_slot("default", "core")
        return
    end
    local decoded_ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
    if not decoded_ok or type(decoded) ~= "table" then
        state.players = {}
        apply_slot("default", "core")
        return
    end
    if type(decoded.players) == "table" then
        state.players = decoded.players
        for pname in pairs(state.players) do
            ensure_player_record(pname)
        end
        local active = clean_player_name(decoded.active) or "default"
        local gid = (type(decoded.active_game) == "string" and GAMES[decoded.active_game]) and decoded.active_game
            or "core"
        apply_slot(active, gid)
    else
        state.players = {
            default = {
                games = {
                    core = {
                        actions = type(decoded.actions) == "table" and decoded.actions or {},
                        solved = type(decoded.solved) == "table" and decoded.solved or {},
                        harpoon_files = type(decoded.harpoon_files) == "table" and decoded.harpoon_files or {},
                        ai_counts = type(decoded.ai_counts) == "table" and decoded.ai_counts or {},
                        runs = tonumber(decoded.runs) or 0,
                        saved_at = os.date("%Y-%m-%d %H:%M"),
                    },
                },
            },
        }
        apply_slot("default", "core")
    end
end

local function clear_progress()
    state.actions = {}
    state.solved = {}
    state.harpoon_files = {}
    state.ai_counts = {}
    state.announced = {}
    state.runs = 0
    state.saved_lines = nil
    save_progress(false)
end

local function sorted_player_names()
    local names = {}
    for name in pairs(state.players) do
        names[#names + 1] = name
    end
    table.sort(names)
    return names
end

local function level_range(lines, level, comment)
    local p = comment or "%-%-"
    local tag = string.format("%02d", level)
    local start_i, end_i
    for i, line in ipairs(lines) do
        if not start_i and line:match("^" .. p .. " NIVO " .. tag .. "[^%d]") then
            start_i = i
        elseif
            start_i
            and (
                line:match("^" .. p .. " NIVO %d")
                or line:match("^" .. p .. " =====")
                or line:match("^%-%-%-%s*$")
                or line:match("^%-%- Izvoz da Lua")
                or line:match("^M%.refs%s*=")
            )
        then
            end_i = i - 1
            break
        end
    end
    if not start_i then
        return nil, nil
    end
    return start_i, end_i or #lines
end

local function extract_play(lines, level, comment)
    local p = comment or "%-%-"
    local start_i, end_i = level_range(lines, level, p)
    if not start_i then
        return ""
    end
    local from = start_i
    for i = start_i, end_i do
        if lines[i]:match("^" .. p .. " IGRAJ OVDE:") then
            from = i + 1
            break
        end
    end
    local to = end_i
    for i = from, end_i do
        if lines[i]:match("^" .. p .. " OCEKIVANI") then
            to = i - 1
            break
        end
    end
    if from > to then
        return ""
    end
    return table.concat(lines, "\n", from, to)
end

local play_cache = setmetatable({}, { __mode = "k" })

local function play(lines, level, comment)
    local p = comment or "%-%-"
    local cached = play_cache[lines]
    if not cached then
        cached = {}
        play_cache[lines] = cached
    end
    local key = p .. ":" .. tostring(level)
    if cached[key] == nil then
        cached[key] = extract_play(lines, level, p)
    end
    return cached[key]
end

local function oneline(text, pat)
    for line in text:gmatch("[^\n]+") do
        if line:match(pat) then
            return true
        end
    end
    return false
end

local function ordered_lines(text, pats)
    local index = 1
    for line in text:gmatch("[^\n]+") do
        if index <= #pats and line:match(pats[index]) then
            index = index + 1
        end
    end
    return index > #pats
end

local function ordered_plain(text, needles)
    local pos = 1
    for _, needle in ipairs(needles) do
        local found = text:find(needle, pos, true)
        if not found then
            return false
        end
        pos = found + #needle
    end
    return true
end

local function count_plain(text, needle)
    local total, from = 0, 1
    while true do
        local found = text:find(needle, from, true)
        if not found then
            return total
        end
        total = total + 1
        from = found + #needle
    end
end

local function fn_body(text, name_pat)
    local body = {}
    local inside = false
    for line in text:gmatch("[^\n]+") do
        if not inside and line:match(name_pat) then
            inside = true
        elseif inside then
            if line:match("^%s*end%s*$") then
                break
            end
            if line:match("%S") then
                body[#body + 1] = line
            end
        end
    end
    return body
end

local function pipeline_slot(text, idx, needle)
    local items = {}
    local inside = false
    for line in text:gmatch("[^\n]+") do
        if not inside and line:match("nivo_04_pipeline%s*=%s*{") then
            inside = true
        elseif inside then
            if line:match("^%s*}") then
                break
            end
            local item = line:match('"(.-)"')
            if item then
                items[#items + 1] = item
            end
        end
    end
    return items[idx] == needle
end

local function first_table_field(text, table_pat, field_pat)
    local inside = false
    for line in text:gmatch("[^\n]+") do
        if not inside and line:match(table_pat) then
            inside = true
        elseif inside then
            if line:match("^%s*}") then
                break
            end
            if line:match("%S") then
                return line:match(field_pat) ~= nil
            end
        end
    end
    return false
end

local function A(label, id, step)
    return {
        label = label,
        step = step,
        test = function(_, ctx)
            return ctx.actions[id] == true
        end,
    }
end

local function code(label, fn, step, line_pat)
    return {
        label = label,
        step = step,
        line_pat = line_pat,
        test = function(lines)
            return fn(lines) and true or false
        end,
    }
end

local LEVELS = {
    {
        id = 1,
        title = "Cheatsheet",
        goals = {
            A("<leader>?", "01:?", 1),
            A("<leader>wk", "01:wk", 2),
            A("<leader>w?", "01:w?", 3),
        },
    },
    {
        id = 2,
        title = "Skrol i pretraga",
        goals = {
            A("<C-d>", "02:cd", 1),
            A("<C-u>", "02:cu", 1),
            A("/PING_META", "02:search", 2),
            A("n", "02:n", 3),
            A("N", "02:N", 3),
        },
    },
    {
        id = 3,
        title = "Join",
        goals = {
            code("1. spoj", function(lines)
                return oneline(play(lines, 3), '^local%s+nivo_03_cmd%s*=%s*"kubectl"%s*%.%.%s*" get pods"')
            end, nil, "^local%s+nivo_03_cmd%s*="),
            code("2. spoj", function(lines)
                return oneline(play(lines, 3), '" get pods"%s*%.%.%s*" %-n production"')
            end, nil, "^local%s+nivo_03_cmd%s*="),
            code("3. spoj", function(lines)
                return oneline(play(lines, 3), '" %-n production"%s*%.%.%s*" %-o wide"%s*$')
            end, nil, "^local%s+nivo_03_cmd%s*="),
        },
    },
    {
        id = 4,
        title = "Visual move",
        goals = {
            code("1.", function(lines)
                return pipeline_slot(play(lines, 4), 1, "1. git pull")
            end, nil, '"1%. git pull"'),
            code("2.", function(lines)
                return pipeline_slot(play(lines, 4), 2, "2. docker build")
            end, nil, '"2%. docker build"'),
            code("3.", function(lines)
                return pipeline_slot(play(lines, 4), 3, "3. docker push")
            end, nil, '"3%. docker push"'),
            code("4.", function(lines)
                return pipeline_slot(play(lines, 4), 4, "4. helm upgrade")
            end, nil, '"4%. helm upgrade"'),
            code("5.", function(lines)
                return pipeline_slot(play(lines, 4), 5, "5. healthcheck")
            end, nil, '"5%. healthcheck"'),
        },
    },
    {
        id = 5,
        title = "Insert <C-c>",
        goals = {
            code('"HEALTHY"', function(lines)
                return oneline(play(lines, 5), 'nivo_05_status%s*=%s*"HEALTHY"')
            end, 1, "nivo_05_status%s*="),
            code('"v1.0.0"', function(lines)
                return oneline(play(lines, 5), 'nivo_05_version%s*=%s*"v1%.0%.0"')
            end, 2, "nivo_05_version%s*="),
            A("<C-c>", "05:cc", 3),
        },
    },
    {
        id = 6,
        title = "Paste bez gubitka yanka",
        goals = {
            code("api", function(lines)
                return oneline(play(lines, 6), 'api%s*=%s*"8443"')
            end, nil, "^%s*api%s*="),
            code("auth", function(lines)
                return oneline(play(lines, 6), 'auth%s*=%s*"8443"')
            end, nil, "^%s*auth%s*="),
            code("metrics", function(lines)
                return oneline(play(lines, 6), 'metrics%s*=%s*"8443"')
            end, nil, "^%s*metrics%s*="),
        },
    },
    {
        id = 7,
        title = "Void delete",
        goals = {
            code("obrisi junk", function(lines)
                local text = play(lines, 7)
                return text:find("nivo_07_source", 1, true) and not text:find("nivo_07_junk", 1, true)
            end, 2, "nivo_07_junk%s*="),
            code("zameni FIXME", function(lines)
                return oneline(play(lines, 7), 'nivo_07_target%s*=%s*"prod_secret_key"')
            end, 3, "nivo_07_target%s*="),
        },
    },
    {
        id = 8,
        title = "System clipboard",
        goals = {
            A("<leader>Y", "08:line", 1),
            A("<leader>y", "08:char", 2),
        },
    },
    {
        id = 9,
        title = "Zamena reci",
        goals = {
            code("primary", function(lines)
                return oneline(play(lines, 9), 'primary%s*=%s*"novi_klaster_09"')
            end, nil, "^%s*primary%s*="),
            code("backup", function(lines)
                return oneline(play(lines, 9), 'backup%s*=%s*"novi_klaster_09"')
            end, nil, "^%s*backup%s*="),
            code("dns", function(lines)
                return oneline(play(lines, 9), 'dns%s*=%s*"novi_klaster_09"')
            end, nil, "^%s*dns%s*="),
            code("tag", function(lines)
                return oneline(play(lines, 9), 'tag%s*=%s*"novi_klaster_09"')
            end, nil, "^%s*tag%s*="),
        },
    },
    {
        id = 10,
        title = "Komentari",
        goals = {
            code("debug", function(lines)
                return oneline(play(lines, 10), "^%s*%-%-+%s*debug%s*=%s*true")
            end, 1, "debug%s*="),
            code("tls_enabled", function(lines)
                return oneline(play(lines, 10), "^%s*tls_enabled%s*=%s*true")
            end, 2, "tls_enabled%s*="),
            code("tls_cert", function(lines)
                return oneline(play(lines, 10), "^%s*tls_cert%s*=")
            end, 2, "tls_cert%s*="),
            code("tls_key", function(lines)
                return oneline(play(lines, 10), "^%s*tls_key%s*=")
            end, 2, "tls_key%s*="),
        },
    },
    {
        id = 11,
        title = "Dodaj surround",
        goals = {
            code('"eu_west"', function(lines)
                return oneline(play(lines, 11), 'nivo_11_region%s*=%s*"eu_west"%s*$')
            end, 1, "nivo_11_region%s*="),
            code("'my_app'", function(lines)
                return oneline(play(lines, 11), "nivo_11_name%s*=%s*'my_app'%s*$")
            end, 2, "nivo_11_name%s*="),
            code("(x + y)", function(lines)
                return oneline(play(lines, 11), "nivo_11_sum%s*=%s*%(%s*x%s*%+%s*y%s*%)%s*%*%s*2%s*$")
            end, 3, "nivo_11_sum%s*="),
        },
    },
    {
        id = 12,
        title = "Promeni surround",
        goals = {
            code('"ansible"', function(lines)
                return oneline(play(lines, 12), 'nivo_12_a%s*=%s*"ansible"%s*$')
            end, 1, "nivo_12_a%s*="),
            code("'terraform'", function(lines)
                return oneline(play(lines, 12), "nivo_12_b%s*=%s*'terraform'%s*$")
            end, 2, "nivo_12_b%s*="),
            code('{"packer"}', function(lines)
                return oneline(play(lines, 12), 'nivo_12_c%s*=%s*{%s*"packer"%s*}%s*$')
            end, 3, "nivo_12_c%s*="),
        },
    },
    {
        id = 13,
        title = "Obrisi surround",
        goals = {
            code("42", function(lines)
                return oneline(play(lines, 13), "^%s*local%s+nivo_13_num%s*=%s*42%s*$")
            end, 1, "nivo_13_num%s*="),
            code("100", function(lines)
                return oneline(play(lines, 13), "^%s*local%s+nivo_13_deep%s*=%s*100%s*$")
            end, 2, "nivo_13_deep%s*="),
            code("true", function(lines)
                return oneline(play(lines, 13), "^%s*local%s+nivo_13_flag%s*=%s*true%s*$")
            end, 3, "nivo_13_flag%s*="),
        },
    },
    {
        id = 14,
        title = "Surround combo",
        goals = {
            code("name", function(lines)
                return oneline(play(lines, 14), 'name%s*=%s*"host_name"%s*,?%s*$')
            end, nil, "^%s*name%s*="),
            code("role", function(lines)
                return oneline(play(lines, 14), 'role%s*=%s*"worker"%s*,?%s*$')
            end, nil, "^%s*role%s*="),
            code("env", function(lines)
                return oneline(play(lines, 14), 'env%s*=%s*"prod"%s*,?%s*$')
            end, nil, "^%s*env%s*="),
        },
    },
    {
        id = 15,
        title = "Skok po funkcijama",
        goals = {
            A("]f", "15:nextf"),
            A("TAJNA_SIFRA", "15:found"),
        },
    },
    {
        id = 16,
        title = "Function inner",
        goals = {
            code("return a + b", function(lines)
                local body = fn_body(play(lines, 16), "function%s+nivo_16_bloated%s*%(")
                return #body == 1 and body[1]:match("^%s*return%s+a%s*%+%s*b%s*$") ~= nil
            end, nil, "function%s+nivo_16_bloated"),
        },
    },
    {
        id = 17,
        title = "Function outer",
        goals = {
            code("daf deprecated", function(lines)
                local text = play(lines, 17)
                return text:find("function nivo_17_keep_me", 1, true) ~= nil
                    and text:find("nivo_17_deprecated", 1, true) == nil
            end, nil, "function%s+nivo_17_deprecated"),
        },
    },
    {
        id = 18,
        title = "Parametri",
        goals = {
            code("obrisi unused_flag", function(lines)
                local text = play(lines, 18)
                return oneline(text, "function%s+nivo_18_deploy%s*%(%s*env%s*,%s*replicas%s*%)")
                    and not text:find("unused_flag", 1, true)
            end, 1, "function%s+nivo_18_deploy"),
            code('"prod"', function(lines)
                local text = play(lines, 18)
                return oneline(text, 'nivo_18_deploy%s*%(%s*"prod"') and not text:find('"staging"', 1, true)
            end, 2, "return%s+nivo_18_deploy"),
            code("obrisi false", function(lines)
                local text = play(lines, 18)
                return oneline(text, "nivo_18_deploy%s*%([^%)]*,%s*3%s*%)") and not text:find("false", 1, true)
            end, 3, "return%s+nivo_18_deploy"),
        },
    },
    {
        id = 19,
        title = "Pomeri funkciju",
        goals = {
            code("first iznad second", function(lines)
                local text = play(lines, 19)
                local first = text:find("function nivo_19_first", 1, true)
                local second = text:find("function nivo_19_second", 1, true)
                return first ~= nil and second ~= nil and first < second
            end, nil, "function%s+nivo_19_first"),
        },
    },
    {
        id = 20,
        title = "Snacks picker",
        goals = {
            A("<leader>pf", "20:pf", 1),
            A("ai.lua", "20:ai", 1),
            A("<leader>pb", "20:pb", 2),
            A("<C-p>", "20:cp", 3),
            A("<leader>vh", "20:vh", 4),
        },
    },
    {
        id = 21,
        title = "Snacks grep",
        goals = {
            A("<leader>pws", "21:pws", 1),
            A("<leader>pWs", "21:pWs", 2),
            A("<leader>ps", "21:ps", 3),
        },
    },
    {
        id = 22,
        title = "Oil",
        goals = {
            A("-", "22:oil", 1),
            A("lua/fikolis/lazy", "22:lazy", 2),
            A("nazad na dojo", "22:back", 3),
        },
    },
    {
        id = 23,
        title = "Harpoon",
        goals = {
            {
                label = "learn_nvim.lua",
                step = 1,
                test = function(_, ctx)
                    return (ctx.harpoon_files or {})["learn_nvim.lua"] == true
                end,
            },
            {
                label = "remap.lua",
                step = 2,
                test = function(_, ctx)
                    return (ctx.harpoon_files or {})["remap.lua"] == true
                end,
            },
            {
                label = "ai.lua",
                step = 3,
                test = function(_, ctx)
                    return (ctx.harpoon_files or {})["ai.lua"] == true
                end,
            },
            A("<C-e>", "23:menu", 4),
            A("<C-j>", "23:j", 5),
            A("<C-k>", "23:k", 5),
            A("<C-h>", "23:h", 5),
        },
    },
    {
        id = 24,
        title = "Zen i Undotree",
        goals = {
            A("<leader>zz", "24:zz", 1),
            A("<leader>zZ", "24:zZ", 1),
            A("<leader>u", "24:u", 3),
            code('"DRUGA"', function(lines)
                return oneline(play(lines, 24), 'nivo_24_history%s*=%s*"DRUGA"')
            end, 3, "nivo_24_history%s*="),
        },
    },
    {
        id = 25,
        title = "LSP navigacija",
        goals = {
            A("K", "25:K", 2),
            A("gd", "25:gd", 3),
            A("<leader>vrr", "25:vrr", 4),
            A("<leader>vws", "25:vws", 5),
        },
    },
    {
        id = 26,
        title = "Rename i completion",
        goals = {
            code("novi_brojac", function(lines)
                local text = play(lines, 26)
                return not text:find("stari_brojac", 1, true) and count_plain(text, "novi_brojac") >= 3
            end, 1, "local%s+[%w_]*brojac"),
            A("completion", "26:cmp", 2),
            A("<C-h>", "26:ch", 3),
        },
    },
    {
        id = 27,
        title = "Dijagnostika",
        goals = {
            A("]d", "27:d", 1),
            A("<leader>vd", "27:vd", 2),
            A("<leader>qb", "27:qb", 3),
            A("<leader>qs", "27:qs", 4),
            A("<leader>pd", "27:pd", 5),
            A("<leader>vca", "27:vca", 5),
        },
    },
    {
        id = 28,
        title = "Format",
        goals = {
            code("stylua", function(lines)
                local text = play(lines, 28)
                return oneline(text, "^local function nivo_28_messy%(a, b, c%)%s*$")
                    and oneline(text, "^%s+local x = a %+ b%s*$")
                    and oneline(text, "^%s+if x > c then%s*$")
                    and oneline(text, "^%s+return { a, b, c }%s*$")
                    and oneline(text, "^%s+return { c }%s*$")
            end, nil, "function%s+nivo_28_messy"),
        },
    },
    {
        id = 29,
        title = "Git",
        goals = {
            A("<leader>ghp", "29:ghp", 1),
            A("]h", "29:h", 2),
            A("<leader>ghr", "29:ghr", 3),
            A("<leader>gl", "29:gl", 4),
            A("<leader>gs", "29:gs", 4),
        },
    },
    {
        id = 30,
        title = "AI float",
        goals = {
            A("AI float", "30:open", 1),
            A("<C-q>", "30:cq", 2),
            A("isti shortcut opet", "30:reopen", 3),
        },
    },
    {
        id = 31,
        title = "Boss 1",
        goals = {
            code("legacy komentar", function(lines)
                return oneline(play(lines, 31), "^%s*%-%-+%s*legacy%s*=%s*true")
            end, 1, "legacy%s*="),
            code("name prvi", function(lines)
                return first_table_field(play(lines, 31), "nivo_31_service%s*=%s*{", 'name%s*=%s*"payments%-api"')
            end, 2, "name%s*="),
            code("port 8080", function(lines)
                return oneline(play(lines, 31), "port%s*=%s*8080%s*,?%s*$")
            end, 3, "port%s*="),
            code('"eu-central-1"', function(lines)
                return oneline(play(lines, 31), 'region%s*=%s*"eu%-central%-1"')
            end, 4, "region%s*="),
            code("primary_env", function(lines)
                return oneline(play(lines, 31), 'primary_env%s*=%s*"production"')
            end, 5, "primary_env%s*="),
            code("fallback_env", function(lines)
                return oneline(play(lines, 31), 'fallback_env%s*=%s*"production"')
            end, 5, "fallback_env%s*="),
        },
    },
    {
        id = 32,
        title = "Boss 2",
        goals = {
            code("obrisi dead_arg", function(lines)
                local text = play(lines, 32)
                return oneline(text, "function%s+nivo_32_build%s*%(%s*target%s*,%s*mode%s*%)")
                    and not text:find("dead_arg", 1, true)
            end, 2, "function%s+nivo_32_build"),
            code("runner poziv", function(lines)
                local text = play(lines, 32)
                return oneline(text, 'nivo_32_build%("linux%-amd64", "release"%)')
                    and not text:find("true", 1, true)
                    and not text:find("'debug'", 1, true)
                    and not text:find('"debug"', 1, true)
            end, 3, "return%s+nivo_32_build"),
            code("skini (target)", function(lines)
                local text = play(lines, 32)
                return oneline(text, 'return%s+target%s*%.%.%s*":"%s*%.%.%s*mode')
                    and not text:find("(target)", 1, true)
            end, 4, "return%s+.*target"),
            code("format <leader>f", function(lines)
                local text = play(lines, 32)
                return oneline(text, "^local function nivo_32_build%(target, mode%)%s*$")
                    and oneline(text, '^    return target %.%. ":" %.%. mode%s*$')
            end, 5),
        },
    },
    {
        id = 33,
        title = "Final boss",
        goals = {
            code("obrisi trash", function(lines)
                return not play(lines, 33):find("nivo_33_trash", 1, true)
            end, 1, "function%s+nivo_33_trash"),
            code("cluster_cfg", function(lines)
                local text = play(lines, 33)
                return not text:find("x_cfg", 1, true) and count_plain(text, "cluster_cfg") >= 2
            end, 2, "return%s+[%w_]*cfg"),
            code("v2.5.0 bez junk", function(lines)
                local text = play(lines, 33)
                return not text:find("temp_junk", 1, true) and oneline(text, 'version%s*=%s*"v2%.5%.0"')
            end, 3, "version%s*="),
            code('"k8s"', function(lines)
                return oneline(play(lines, 33), 'engine%s*=%s*"k8s"')
            end, 4, "engine%s*="),
            code("replicas = 3", function(lines)
                return oneline(play(lines, 33), "replicas%s*=%s*3%s*,?%s*$")
            end, 4, "replicas%s*="),
            code("dry_run + redosled", function(lines)
                return ordered_lines(play(lines, 33), {
                    'version%s*=%s*"v2%.5%.0"',
                    "^%s*%-%-+%s*dry_run%s*=%s*true",
                    'engine%s*=%s*"k8s"',
                    "replicas%s*=%s*3%s*,?%s*$",
                })
            end, 5, "dry_run%s*="),
            code("format <leader>f", function(lines)
                local text = play(lines, 33)
                return oneline(text, "^local function nivo_33_deploy_cluster%(%)%s*$")
                    and oneline(text, "^    local cluster_cfg = {$")
            end, 6, "function%s+nivo_33_deploy_cluster"),
        },
    },
}

local TYPED = {
    ["<space>?"] = "01:?",
    ["<space>wk"] = "01:wk",
    ["<space>w?"] = "01:w?",
    ["<c-d>"] = "02:cd",
    ["<c-u>"] = "02:cu",
    ["n"] = "02:n",
    ["N"] = "02:N",
    ["<c-c>"] = "05:cc",
    ["]f"] = "15:nextf",
    ["<space>pf"] = "20:pf",
    ["<c-p>"] = "20:cp",
    ["<space>pb"] = "20:pb",
    ["<space>vh"] = "20:vh",
    ["<space>pws"] = "21:pws",
    ["<space>pWs"] = "21:pWs",
    ["<space>ps"] = "21:ps",
    ["-"] = "22:oil",
    ["<space>a"] = "23:add",
    ["<c-e>"] = "23:menu",
    ["<c-j>"] = "23:j",
    ["<c-k>"] = "23:k",
    ["<space>zz"] = "24:zz",
    ["<space>zZ"] = "24:zZ",
    ["<space>u"] = "24:u",
    ["K"] = "25:K",
    ["gd"] = "25:gd",
    ["<space>vrr"] = "25:vrr",
    ["<space>vws"] = "25:vws",
    ["<c-n>"] = "26:cmp",
    ["<c-y>"] = "26:cmp",
    ["<c-space>"] = "26:cmp",
    ["<nul>"] = "26:cmp",
    ["]d"] = "27:d",
    ["[d"] = "27:d",
    ["<space>vd"] = "27:vd",
    ["<space>qb"] = "27:qb",
    ["<space>qs"] = "27:qs",
    ["<space>pd"] = "27:pd",
    ["<space>vca"] = "27:vca",
    ["<space>ghp"] = "29:ghp",
    ["]h"] = "29:h",
    ["[h"] = "29:h",
    ["<space>ghr"] = "29:ghr",
    ["<space>gl"] = "29:gl",
    ["<space>gs"] = "29:gs",
    ["<space>ca"] = "30:ca",
    ["<space>cg"] = "30:cg",
    ["<space>co"] = "30:co",
    ["<space>cx"] = "30:cx",
    ["<c-q>"] = "30:cq",
}

local SCOPE = {
    ["02:cd"] = 2,
    ["05:cc"] = 5,
    ["15:nextf"] = 15,
    ["25:K"] = 25,
    ["25:gd"] = 25,
    ["26:cmp"] = 26,
    ["26:ch"] = 26,
}

local INSERT = {
    ["05:cc"] = true,
    ["26:cmp"] = true,
    ["26:ch"] = true,
}

local ANY_BUF = {
    ["20:pb"] = true,
    ["23:add"] = true,
    ["23:menu"] = true,
    ["23:j"] = true,
    ["23:k"] = true,
    ["23:h"] = true,
    ["27:qb"] = true,
    ["27:qs"] = true,
    ["27:pd"] = true,
    ["29:ghp"] = true,
    ["29:h"] = true,
    ["29:ghr"] = true,
    ["29:gl"] = true,
    ["29:gs"] = true,
    ["30:cq"] = true,
}

local AI = {
    ["30:ca"] = true,
    ["30:cg"] = true,
    ["30:co"] = true,
    ["30:cx"] = true,
}

local function define_hl()
    vim.api.nvim_set_hl(0, "DojoDone", { fg = "#a6e3a1", bold = true })
    vim.api.nvim_set_hl(0, "DojoTodo", { fg = "#f9e2af", bold = true })
    vim.api.nvim_set_hl(0, "DojoPending", { fg = "#6c7086" })
end

local function dojo_bufs(game_id)
    local list = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local gid = vim.b[buf].learn_dojo
        if gid and vim.api.nvim_buf_is_loaded(buf) and (not game_id or gid == game_id) then
            list[#list + 1] = buf
        end
    end
    return list
end

local function detect_game_id(name)
    local tail = vim.fn.fnamemodify(name or "", ":t")
    for _, gid in ipairs(GAMES_ORDER) do
        if GAMES[gid] and GAMES[gid].file == tail then
            return gid
        end
    end
    return nil
end

local function active_game(buf)
    if buf and vim.api.nvim_buf_is_valid(buf) then
        local gid = vim.b[buf].learn_dojo
        if type(gid) == "string" and GAMES[gid] then
            return GAMES[gid]
        end
    end
    return GAMES[state.game] or GAMES.core
end

local function current_dojo()
    local buf = vim.api.nvim_get_current_buf()
    if vim.b[buf].learn_dojo then
        return buf
    end
    return dojo_bufs(state.game)[1] or dojo_bufs()[1]
end

local function dojo_current()
    return vim.b[vim.api.nvim_get_current_buf()].learn_dojo ~= nil
end

local function ensure_game_for_buf(buf)
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return nil
    end
    local gid = vim.b[buf].learn_dojo
    if type(gid) ~= "string" or not GAMES[gid] then
        return nil
    end
    if state.game ~= gid then
        local prev_buf = dojo_bufs(state.game)[1]
        if prev_buf and vim.api.nvim_buf_is_valid(prev_buf) then
            sync_active_slot(vim.api.nvim_buf_get_lines(prev_buf, 0, -1, false), disk_sig_for(prev_buf))
        else
            sync_active_slot()
        end
        apply_slot(state.player, gid)
        write_store()
    end
    return GAMES[gid]
end

local function section_at(buf, lnum)
    local game = active_game(buf)
    local p = game and game.comment or "%-%-"
    local lines = vim.api.nvim_buf_get_lines(buf, 0, lnum, false)
    local current
    for _, line in ipairs(lines) do
        local n = line:match("^" .. p .. " NIVO (%d+)")
        if n then
            current = tonumber(n)
        end
    end
    return current
end

local function section_now()
    local buf = vim.api.nvim_get_current_buf()
    if not vim.b[buf].learn_dojo then
        return nil
    end
    return section_at(buf, vim.api.nvim_win_get_cursor(0)[1])
end

function M.evaluate(lines, ctx, game_id)
    ctx = ctx or state
    ctx.actions = ctx.actions or {}
    ctx.solved = ctx.solved or {}
    ctx.harpoon_files = ctx.harpoon_files or {}
    local game = GAMES[game_id or state.game] or GAMES.core
    local levels = game.levels
    local results = {}
    local done_n = 0
    for _, level in ipairs(levels) do
        local total = #level.goals
        local have = 0
        local missing = {}
        local goal_states = {}
        local already_solved = ctx.solved[tostring(level.id)] == true and total > 0
        for _, goal in ipairs(level.goals) do
            local passed = already_solved
            if not passed then
                local ok, res = pcall(goal.test, lines, ctx)
                passed = ok and res == true
            end
            if passed then
                have = have + 1
            else
                missing[#missing + 1] = goal.label
            end
            goal_states[#goal_states + 1] = {
                label = goal.label,
                step = goal.step,
                line_pat = goal.line_pat,
                passed = passed,
            }
        end
        local done = have == total and total > 0
        if done then
            done_n = done_n + 1
        end
        results[#results + 1] = {
            id = level.id,
            title = level.title,
            done = done,
            have = have,
            total = total,
            missing = missing[1] or "",
            missing_all = table.concat(missing, ", "),
            goals = goal_states,
        }
    end
    return results, done_n
end

local function result_map(results)
    local by_id = {}
    for _, result in ipairs(results) do
        by_id[result.id] = result
    end
    return by_id
end

local function fingerprint(results)
    local parts = {}
    for _, result in ipairs(results) do
        local bits = {}
        for _, g in ipairs(result.goals or {}) do
            bits[#bits + 1] = g.passed and "1" or "0"
        end
        parts[#parts + 1] = table.concat(bits)
    end
    return table.concat(parts, "|")
end

local function put_mark(buf, lnum, opts)
    if pcall(vim.api.nvim_buf_set_extmark, buf, NS, lnum, 0, opts) then
        return
    end
    opts.sign_text = nil
    opts.sign_hl_group = nil
    pcall(vim.api.nvim_buf_set_extmark, buf, NS, lnum, 0, opts)
end

local function draw_group_mark(buf, lnum, group_goals)
    local passed_n = 0
    for _, g in ipairs(group_goals) do
        if g.passed then
            passed_n = passed_n + 1
        end
    end
    if passed_n == #group_goals then
        put_mark(buf, lnum, {
            sign_text = "✓",
            sign_hl_group = "DojoDone",
            virt_text = { { "   ✓", "DojoDone" } },
            virt_text_pos = "eol",
            priority = 200,
        })
    elseif passed_n == 0 then
        put_mark(buf, lnum, {
            virt_text = { { "   [ ]", "DojoPending" } },
            virt_text_pos = "eol",
            priority = 200,
        })
    else
        local chunks = { { "   ", "DojoTodo" } }
        for idx, g in ipairs(group_goals) do
            if idx > 1 then
                chunks[#chunks + 1] = { "  ", "DojoPending" }
            end
            if g.passed then
                chunks[#chunks + 1] = { "✓ " .. g.label, "DojoDone" }
            else
                chunks[#chunks + 1] = { "[ ] " .. g.label, "DojoTodo" }
            end
        end
        put_mark(buf, lnum, {
            sign_text = "•",
            sign_hl_group = "DojoTodo",
            virt_text = chunks,
            virt_text_pos = "eol",
            priority = 200,
        })
    end
end

local function draw_marks(buf, lines, results)
    vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)
    local game = active_game(buf)
    local p = game and game.comment or "%-%-"
    local by_id = result_map(results)
    local cur_steps = nil
    local cur_line_groups = nil
    local in_play = false

    for i, line in ipairs(lines) do
        local n = line:match("^" .. p .. " NIVO (%d+)")
        if n then
            local cur_result = by_id[tonumber(n)]
            cur_steps = nil
            cur_line_groups = nil
            in_play = false
            if cur_result then
                local hl, text, sign
                if cur_result.done then
                    hl = "DojoDone"
                    text = "   ✓ GOTOVO"
                    sign = "✓"
                elseif cur_result.have > 0 then
                    hl = "DojoTodo"
                    text = string.format("   [•] %d/%d", cur_result.have, cur_result.total)
                    sign = "•"
                else
                    hl = "DojoPending"
                    text = cur_result.total > 1 and string.format("   [ ] 0/%d", cur_result.total) or "   [ ]"
                end
                put_mark(buf, i - 1, {
                    sign_text = sign,
                    sign_hl_group = sign and hl or nil,
                    virt_text = { { text, hl } },
                    virt_text_pos = "eol",
                    priority = 200,
                })

                local steps = {}
                local line_groups = {}
                local line_by_pat = {}
                for _, g in ipairs(cur_result.goals or {}) do
                    if g.step then
                        steps[g.step] = steps[g.step] or {}
                        steps[g.step][#steps[g.step] + 1] = g
                    end
                    if g.line_pat then
                        local grp = line_by_pat[g.line_pat]
                        if not grp then
                            grp = { pat = g.line_pat, goals = {} }
                            line_by_pat[g.line_pat] = grp
                            line_groups[#line_groups + 1] = grp
                        end
                        grp.goals[#grp.goals + 1] = g
                    end
                end
                if next(steps) ~= nil then
                    cur_steps = steps
                end
                if #line_groups > 0 then
                    cur_line_groups = line_groups
                end
            end
        elseif line:match("^" .. p .. " IGRAJ OVDE:") then
            cur_steps = nil
            in_play = true
        elseif line:match("^" .. p .. " OCEKIVANI") or line:match("^" .. p .. " =====") or line:match("^%-%-%-%s*$") then
            cur_steps = nil
            in_play = false
        elseif cur_steps and line:match("^" .. p) then
            local step_num = tonumber(line:match("^" .. p .. "%s+(%d+)%.%s"))
            local group_goals = step_num and cur_steps[step_num]
            if group_goals then
                cur_steps[step_num] = nil
                draw_group_mark(buf, i - 1, group_goals)
            end
        elseif in_play and cur_line_groups then
            for idx, grp in ipairs(cur_line_groups) do
                if line:match(grp.pat) then
                    draw_group_mark(buf, i - 1, grp.goals)
                    table.remove(cur_line_groups, idx)
                    break
                end
            end
        end
    end
end

local function paint_winbar(buf, results, done_n)
    local game = active_game(buf)
    local total_levels = #game.levels
    local section
    if vim.api.nvim_get_current_buf() == buf then
        section = section_at(buf, vim.api.nvim_win_get_cursor(0)[1])
    end
    local by_id = result_map(results)
    local extra = ""
    if section and by_id[section] then
        local result = by_id[section]
        if result.done then
            extra = string.format("%%#DojoDone#   ✓ NIVO %02d GOTOV", section)
        else
            local items = {}
            for _, g in ipairs(result.goals or {}) do
                local safe = g.label:gsub("%%", "%%%%")
                if g.passed then
                    items[#items + 1] = "%#DojoDone#[✓ " .. safe .. "]"
                else
                    items[#items + 1] = "%#DojoTodo#[  " .. safe .. "]"
                end
            end
            extra = string.format(
                "%%#DojoTodo#   NIVO %02d (%d/%d)  %s",
                section,
                result.have,
                result.total,
                table.concat(items, " ")
            )
        end
    end
    local runs = (state.runs or 0) > 0 and ("  runda " .. state.runs) or ""
    local player = (state.player or "default"):gsub("%%", "%%%%")
    local bar = string.format("%%#DojoDone# DOJO [%s] %d/%d%s%s", player, done_n, total_levels, runs, extra)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
            pcall(vim.api.nvim_set_option_value, "winbar", bar, { win = win })
        end
    end
end

local function apply_buffer_lines(buf, lines)
    if not vim.api.nvim_buf_is_valid(buf) or type(lines) ~= "table" then
        return
    end
    local cursors = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
            cursors[win] = vim.api.nvim_win_get_cursor(win)
        end
    end
    local was = state.pausing[buf]
    state.pausing[buf] = true
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modified = false
    local max = vim.api.nvim_buf_line_count(buf)
    for win, cursor in pairs(cursors) do
        if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_set_cursor, win, { math.min(cursor[1], max), cursor[2] })
        end
    end
    state.pausing[buf] = was
end

local function restore_buf(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" then
        return
    end
    local lines = vim.fn.readfile(name)
    apply_buffer_lines(buf, lines)
end

local refresh

local function maybe_victory(buf, results, done_n)
    local game = active_game(buf)
    local total = #game.levels
    if done_n ~= total or state.victory[buf] or state.pausing[buf] then
        return
    end
    state.victory[buf] = true
    state.pausing[buf] = true
    vim.bo[buf].modifiable = false
    vim.notify(string.format("Sve %d vezbe su gotove (%s). Fajl se vraca na pocetak.", total, game.title), vim.log.levels.INFO)
    vim.defer_fn(function()
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end
        vim.bo[buf].modifiable = true
        restore_buf(buf)
        state.actions = {}
        state.solved = {}
        state.harpoon_files = {}
        state.ai_counts = {}
        state.announced = {}
        state.saved_lines = nil
        state.runs = (state.runs or 0) + 1
        save_progress(false)
        state.pausing[buf] = false
        state.victory[buf] = nil
        state.seen_fp[buf] = nil
        refresh(buf, false)
        vim.notify(
            string.format("Dojo je resetovan. Zavrsenih rundi: %d.", state.runs),
            vim.log.levels.INFO
        )
    end, 1500)
end

refresh = function(buf, announce)
    if not vim.api.nvim_buf_is_valid(buf) or state.pausing[buf] then
        return
    end
    local game = ensure_game_for_buf(buf) or active_game(buf)
    local total = #game.levels
    local cursor_changed = false
    if game.id == "core" and vim.api.nvim_get_current_buf() == buf then
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local near = vim.api.nvim_buf_get_lines(buf, math.max(0, row - 1), row + 1, false)
        local joined = table.concat(near, "\n")
        if
            (joined:find("TAJNA_SIFRA", 1, true) or joined:find("function nivo_15_gamma", 1, true))
            and not state.actions["15:found"]
        then
            state.actions["15:found"] = true
            cursor_changed = true
        end
    end
    if cursor_changed then
        save_progress()
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local results, done_n = M.evaluate(lines, state, game.id)
    local solved_changed = false
    for _, result in ipairs(results) do
        local key = tostring(result.id)
        if result.done and not state.solved[key] then
            state.solved[key] = true
            solved_changed = true
        end
    end
    if solved_changed then
        save_progress()
    end
    local fp = tostring(vim.api.nvim_buf_get_changedtick(buf)) .. ":" .. fingerprint(results)
    if state.seen_fp[buf] ~= fp then
        state.seen_fp[buf] = fp
        draw_marks(buf, lines, results)
    end
    paint_winbar(buf, results, done_n)

    if not state.armed[buf] then
        state.armed[buf] = true
        if not announce then
            for _, result in ipairs(results) do
                if result.done then
                    state.announced[result.id] = true
                end
            end
            return
        end
    end

    for _, result in ipairs(results) do
        if result.done then
            if not state.announced[result.id] then
                state.announced[result.id] = true
                if announce then
                    vim.notify(
                        string.format("Nivo %02d gotov (%d/%d) — %s", result.id, done_n, total, result.title),
                        vim.log.levels.INFO
                    )
                end
            end
        else
            state.announced[result.id] = nil
        end
    end

    maybe_victory(buf, results, done_n)
end

local queued = {}
local queued_announce = {}
local function schedule_refresh(buf, announce)
    if state.pausing[buf] then
        return
    end
    if announce then
        queued_announce[buf] = true
    end
    if queued[buf] then
        return
    end
    queued[buf] = true
    vim.defer_fn(function()
        queued[buf] = nil
        local do_announce = queued_announce[buf] == true
        queued_announce[buf] = nil
        if vim.api.nvim_buf_is_valid(buf) then
            refresh(buf, do_announce)
        end
    end, 80)
end

local scheduled_touch = false
local function touch()
    if scheduled_touch then
        return
    end
    scheduled_touch = true
    vim.schedule(function()
        scheduled_touch = false
        save_progress()
        for _, buf in ipairs(dojo_bufs(state.game)) do
            refresh(buf, true)
        end
    end)
end

local function mark_action(id)
    if state.actions[id] then
        return false
    end
    state.actions[id] = true
    return true
end

local last_handled = {}

local function handle(token, mode)
    if not state.session or state.game ~= "core" or token == nil or token == "" then
        return
    end
    if mode:sub(1, 2) == "no" or mode:sub(1, 1) == "c" then
        return
    end

    local id
    if token == "<c-h>" then
        if mode:sub(1, 1) == "i" then
            id = "26:ch"
        elseif mode == "n" then
            id = "23:h"
        end
    elseif token == "<c-p>" then
        if mode:sub(1, 1) == "i" then
            id = "26:cmp"
        elseif mode == "n" then
            id = "20:cp"
        end
    else
        id = TYPED[token]
    end
    if not id then
        return
    end

    if INSERT[id] then
        if mode:sub(1, 1) ~= "i" then
            return
        end
    elseif id == "30:cq" then
        if mode:sub(1, 1) ~= "t" and mode ~= "n" then
            return
        end
    elseif mode ~= "n" then
        return
    end

    local uv = vim.uv or vim.loop
    local now = uv and uv.hrtime and uv.hrtime() or 0
    if now > 0 and last_handled[id] and (now - last_handled[id]) < 150000000 then
        return
    end
    last_handled[id] = now

    local ai = AI[id]
    if not ANY_BUF[id] and not ai and not dojo_current() then
        return
    end
    if SCOPE[id] and section_now() ~= SCOPE[id] then
        return
    end
    if id == "02:cu" and section_now() ~= 2 and not state.actions["02:cd"] then
        return
    end
    if (id == "02:n" or id == "02:N") and not state.actions["02:search"] then
        return
    end

    if id == "23:add" then
        local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
        if name ~= "" and not state.harpoon_files[name] then
            state.harpoon_files[name] = true
            touch()
        end
        return
    end

    if ai then
        local seen = state.ai_counts[id] or 0
        if seen == 0 and not dojo_current() then
            return
        end
        state.ai_counts[id] = seen + 1
        local changed = mark_action("30:open")
        if state.ai_counts[id] >= 2 then
            changed = mark_action("30:reopen") or changed
        end
        if changed or seen == 0 then
            touch()
        end
        return
    end

    if id == "30:cq" and not state.actions["30:open"] then
        return
    end
    if mark_action(id) then
        touch()
    end
end

local function norm_typed(typed)
    if not typed or typed == "" then
        return nil
    end
    local text = vim.fn.keytrans(typed)
    if text == "" then
        return nil
    end
    text = text:gsub("<[^>]+>", string.lower)
    text = text:gsub("<nl>", "<c-j>")
    return text
end

local wrapped_cbs = setmetatable({}, { __mode = "k" })

local function norm_lhs(lhs)
    if not lhs or lhs == "" then
        return nil
    end
    local ok, raw = pcall(vim.api.nvim_replace_termcodes, lhs, true, true, true)
    if not ok or not raw or raw == "" then
        return nil
    end
    return norm_typed(raw)
end

local function wrap_keymap_list(maps, target_buf)
    for _, m in ipairs(maps) do
        if m.expr ~= 1 and (not m.callback or not wrapped_cbs[m.callback]) then
            local token = norm_lhs(m.lhs)
            local id = token and (token == "<c-h>" and "23:h" or TYPED[token])
            if id and not INSERT[id] then
                local orig_cb = m.callback
                local cmd = (not orig_cb and type(m.rhs) == "string")
                    and m.rhs:match("^<[Cc][Mm][Dd]>(.*)<[Cc][Rr]>$")
                    or nil
                if orig_cb or cmd then
                    local function fn(...)
                        if state.session then
                            pcall(handle, token, "n")
                        end
                        if orig_cb then
                            return orig_cb(...)
                        end
                        vim.cmd(cmd)
                    end
                    wrapped_cbs[fn] = true
                    local opts = {
                        desc = m.desc,
                        silent = m.silent == 1,
                        nowait = m.nowait == 1,
                        remap = m.noremap == 0,
                    }
                    if target_buf then
                        opts.buffer = target_buf
                    end
                    pcall(vim.keymap.set, "n", m.lhs, fn, opts)
                end
            end
        end
    end
end

local function wrap_keymaps(buf)
    wrap_keymap_list(vim.api.nvim_get_keymap("n"), nil)
    if buf and vim.api.nvim_buf_is_valid(buf) then
        wrap_keymap_list(vim.api.nvim_buf_get_keymap(buf, "n"), buf)
    end
end

local function attach(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    local gid = detect_game_id(name)
    if not gid then
        return
    end
    if vim.b[buf].learn_dojo then
        ensure_game_for_buf(buf)
        return
    end
    vim.b[buf].learn_dojo = gid
    state.session = true
    local game = ensure_game_for_buf(buf) or GAMES[gid]
    vim.bo[buf].buftype = "acwrite"
    if can_restore_saved_lines(buf) then
        apply_buffer_lines(buf, state.saved_lines)
    elseif state.saved_lines ~= nil then
        -- Disk file was updated (e.g. git pull); discard stale buffer snapshot while keeping solved progress
        state.saved_lines = nil
        state.saved_disk_sig = nil
        save_progress(false)
    end
    wrap_keymaps(buf)
    vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
            wrap_keymaps(buf)
        end
    end)

    local group = vim.api.nvim_create_augroup("LearnDojo", { clear = false })
    vim.api.nvim_create_autocmd("BufWriteCmd", {
        group = group,
        buffer = buf,
        desc = "Learn dojo cuva igru umesto upisa na disk",
        callback = function()
            M.save_game()
        end,
    })
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = buf,
        callback = function()
            schedule_refresh(buf, true)
        end,
    })
    vim.api.nvim_create_autocmd("BufWinLeave", {
        group = group,
        buffer = buf,
        callback = function()
            local win = vim.api.nvim_get_current_win()
            if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
                pcall(vim.api.nvim_set_option_value, "winbar", "", { win = win })
            end
        end,
    })
    vim.keymap.set("n", "<leader><leader>", function()
        vim.notify("Dojo fajl se ne source-uje.", vim.log.levels.WARN)
    end, { buffer = buf, desc = "Dojo: ne source-uj ovaj fajl" })

    if not state.greeted[gid] then
        state.greeted[gid] = true
        vim.schedule(function()
            local solved_n = count_solved({ solved = state.solved })
            vim.notify(
                string.format(
                    "Dojo [%s] %s (%d/%d) — :DojoGames, :DojoNew, :DojoSave (ili :w), :DojoLoad, :DojoNext",
                    state.player or "default",
                    game.title,
                    solved_n,
                    #game.levels
                ),
                vim.log.levels.INFO
            )
        end)
    end
end

local function focus_dojo(buf)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
            vim.api.nvim_set_current_win(win)
            return true
        end
    end
    vim.api.nvim_set_current_buf(buf)
    return true
end

function M.status()
    local buf = current_dojo()
    if not buf then
        vim.notify("Otvori learning/learn_nvim.lua ili learning/learn_nvim.yaml (ili :DojoGames).", vim.log.levels.WARN)
        return
    end
    local game = ensure_game_for_buf(buf) or active_game(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local results, done_n = M.evaluate(lines, state, game.id)
    local out = {
        string.format(
            "Dojo [%s] %s  %d/%d    rundi: %d    igraca: %d",
            state.player or "default",
            game.title,
            done_n,
            #game.levels,
            state.runs or 0,
            #sorted_player_names()
        ),
    }
    for _, result in ipairs(results) do
        if result.done then
            out[#out + 1] = string.format("  %02d  ✓  %s", result.id, result.title)
        else
            out[#out + 1] = string.format(
                "  %02d  %d/%d  %s  ·  fali: %s",
                result.id,
                result.have,
                result.total,
                result.title,
                result.missing_all
            )
        end
    end
    vim.notify(table.concat(out, "\n"), vim.log.levels.INFO)
end

function M.next()
    local buf = current_dojo()
    if not buf then
        vim.notify("Otvori igru sa :DojoGames.", vim.log.levels.WARN)
        return
    end
    focus_dojo(buf)
    local game = ensure_game_for_buf(buf) or active_game(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local results = M.evaluate(lines, state, game.id)
    local target
    for _, result in ipairs(results) do
        if not result.done then
            target = result.id
            break
        end
    end
    if not target then
        vim.notify("Sve vezbe su gotove.", vim.log.levels.INFO)
        return
    end
    local tag = string.format("%02d", target)
    local p = game.comment or "%-%-"
    for i, line in ipairs(lines) do
        if line:match("^" .. p .. " NIVO " .. tag .. "[^%d]") then
            vim.api.nvim_win_set_cursor(0, { i, 0 })
            vim.cmd("normal! zz")
            refresh(buf, false)
            return
        end
    end
end

local HINTS = {
    { pat = "ysiw", text = 'ysiw"   = You Surround Inner Word — obavij rec pod kursorom (npr. ysiw" -> "rec")' },
    { pat = "yss", text = "yss)    = You Surround Line — obavij celu liniju u zagrade" },
    { rx = "%f[%w]ys[%w\"'%(%)%{%}%[%]<]", text = 'ys<m><c>= You Surround — dodaj okruzenje oko motion-a (npr. ysiw" ili ys3w))' },
    { rx = "%f[%w]cs[\"'%(%)%{%}%[%]<>]", text = "cs'\"    = Change Surround — promeni okruzenje (npr. cs'\" menja ' u \", cs)} menja () u {})" },
    { rx = "%f[%w]ds[\"'%(%)%{%}%[%]<>]", text = 'ds)     = Delete Surround — obrisi okruzujuce karaktere (ds) skida (), ds" skida "")' },
    { rx = "%f[%w]ciw%f[^%w]", text = "ciw     = Change Inner Word — obrisi rec pod kursorom i udji u Insert mod" },
    { pat = 'ci"', text = 'ci"     = Change Inner "..." — obrisi sve unutar navodnika i udji u Insert mod' },
    { pat = "ct:", text = "ct:     = Change Till ':' — obrisi sve od kursora DO dvotacke i udji u Insert mod" },
    { pat = 'yi"', text = 'yi"     = Yank Inner "..." — kopiraj tekst unutar navodnika (bez samih navodnika)' },
    { rx = "%f[%w]yiw%f[^%w]", text = "yiw     = Yank Inner Word — kopiraj rec pod kursorom" },
    { pat = "<leader>p", text = 'vi"<leader>p = Visual Inner "..." + Paste bez gubitka yanka (stari yank ostaje u registru!)' },
    { pat = "<leader>dd", text = "<leader>dd   = Delete u crnu rupu (void registar — ne gazi ono sto si kopirao!)" },
    { rx = "<leader>d%f[^%w]", text = "<leader>d    = Delete u crnu rupu (void registar — ne gazi clipboard/yank!)" },
    { rx = "<leader>s%f[^%w]", text = "<leader>s    = Search & Replace reci pod kursorom SVUDA u fajlu odjednom" },
    { pat = "<leader>+", text = "<broj><leader>+ / - = Increment / Decrement broja (tmux-safe zamena za <C-a>/<C-x>)" },
    { rx = "%f[%w]gcc%f[^%w]", text = "gcc     = Toggle Comment na jednoj liniji" },
    { rx = "%f[%w]V?%d*[jk]?gc%f[^%w]", text = "V2jgc   = Visual Line + 2 dole + Toggle Comment na celom bloku" },
    { rx = "%f[%w]V%f[^%w].-[JK]", text = "V + J/K = Visual Line selekcija + pomeri linije dole (J) / gore (K)" },
    { rx = "%f[%w]V%f[^%w].-[%s,`']>", text = "V + >/< = Visual Line selekcija + uvuci (>) / izvuci (<) za 2 razmaka" },
    { pat = "f5r7", text = "f<c>r<x>= Find karakter <c> u liniji + Replace sa <x> (bez ulaska u Insert mod!)" },
    { rx = "%f[%w]cif%f[^%w]", text = "cif     = Change Inner Function — zameni CELO telo funkcije (Treesitter)" },
    { rx = "%f[%w]daf%f[^%w]", text = "daf     = Delete Around Function — obrisi celu funkciju od local do end (Treesitter)" },
    { rx = "%f[%w]yaf%f[^%w]", text = "yaf     = Yank Around Function — kopiraj celu funkciju od local do end (Treesitter)" },
    { rx = "%f[%w]vaf%f[^%w]", text = "vaf     = Visual Around Function — selektuj celu funkciju (pa J/K ili <leader>f)" },
    { rx = "%f[%w]cia%f[^%w]", text = "cia     = Change Inner Argument — promeni parametar/argument funkcije (Treesitter)" },
    { rx = "%f[%w]daa%f[^%w]", text = "daa     = Delete Around Argument — obrisi argument ZAJEDNO sa zarezom (Treesitter)" },
    { pat = "]f", text = "]f / [f = Skok na sledecu / prethodnu funkciju (Treesitter)" },
    { pat = "<C-c>", text = "<C-c>   = Brzi izlaz iz Insert moda (remap za <Esc>)" },
    { pat = "<C-y>", text = "<C-n>/<C-p> + <C-y> = Listaj autocomplete predloge i potvrdi izbor (blink.cmp)" },
    { rx = "<leader>f%f[^%w]", text = "<leader>f = Formatiraj bafer ili Visual selekciju (Conform)" },
    { rx = "<leader>u%f[^%w]", text = "<leader>u = Otvori Undotree (sve grane istorije izmena)" },
}

function M.hint()
    local buf = current_dojo()
    if not buf then
        vim.notify("Otvori igru sa :DojoGames.", vim.log.levels.WARN)
        return
    end
    local game = ensure_game_for_buf(buf) or active_game(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local level_id = section_at(buf, vim.api.nvim_win_get_cursor(0)[1])
    if not level_id then
        vim.notify("Stani unutar nekog nivoa pa pokreni :DojoHint.", vim.log.levels.INFO)
        return
    end
    local s, e = level_range(lines, level_id, game.comment)
    if not s then
        return
    end
    local header_block = {}
    for i = s, e do
        if lines[i]:match("^" .. game.comment .. " IGRAJ OVDE:") then
            break
        end
        header_block[#header_block + 1] = lines[i]
    end
    local blob = table.concat(header_block, "\n")
    local matched = {}
    local seen = {}
    for _, h in ipairs(HINTS) do
        local hit = h.rx and (blob:find(h.rx) ~= nil) or (h.pat and blob:find(h.pat, 1, true) ~= nil)
        if hit and not seen[h.text] then
            seen[h.text] = true
            matched[#matched + 1] = "  • " .. h.text
        end
    end
    if #matched == 0 then
        vim.notify(string.format("Nivo %02d: koristi :Dojo za status ili <Space>? za sve precice.", level_id), vim.log.levels.INFO)
        return
    end
    vim.notify(string.format("HINT — Nivo %02d (%s):\n%s", level_id, game.title, table.concat(matched, "\n")), vim.log.levels.INFO)
end

function M.reset_text()
    local buf = current_dojo()
    if not buf then
        vim.notify("Otvori igru sa :DojoGames.", vim.log.levels.WARN)
        return
    end
    ensure_game_for_buf(buf)
    restore_buf(buf)
    state.saved_lines = nil
    save_progress(false)
    state.seen_fp[buf] = nil
    refresh(buf, false)
    vim.notify("Tekst dojo fajla je vracen na disk verziju. Sacuvani napredak ostaje.", vim.log.levels.INFO)
end

local function resolve_game_path(game)
    local candidates = {
        vim.fn.getcwd() .. "/" .. game.rel,
        vim.fn.stdpath("config") .. "/" .. game.rel,
        vim.fn.getcwd() .. "/" .. game.file,
        vim.fn.stdpath("config") .. "/" .. game.file,
    }
    for _, path in ipairs(candidates) do
        if vim.fn.filereadable(path) == 1 then
            return path
        end
    end
    return vim.fn.stdpath("config") .. "/" .. game.rel
end

function M.games(target)
    local function open_game(gid)
        local game = GAMES[gid]
        if not game then
            vim.notify("Nepoznata igra: " .. tostring(gid), vim.log.levels.WARN)
            return
        end
        local path = resolve_game_path(game)
        if vim.fn.filereadable(path) ~= 1 then
            vim.notify("Fajl igre nije pronadjen: " .. path, vim.log.levels.WARN)
            return
        end
        local cur = current_dojo()
        if cur and vim.b[cur].learn_dojo and vim.b[cur].learn_dojo ~= gid then
            save_progress(vim.api.nvim_buf_get_lines(cur, 0, -1, false), disk_sig_for(cur))
        end
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        local buf = vim.api.nvim_get_current_buf()
        attach(buf)
        refresh(buf, false)
        M.next()
    end

    local clean = clean_player_name(target)
    if clean then
        open_game(clean)
        return
    end

    local items = {}
    for _, gid in ipairs(GAMES_ORDER) do
        local g = GAMES[gid]
        if g then
            local slot = get_player_game_slot(state.player, gid)
            items[#items + 1] = { game = g, solved = count_solved(slot), runs = tonumber(slot.runs) or 0 }
        end
    end

    vim.ui.select(items, {
        prompt = string.format("Dojo igre [%s]:", state.player or "default"),
        format_item = function(item)
            local g = item.game
            local mark = (g.id == state.game) and "* " or "  "
            return string.format(
                "%s%-26s %2d/%-2d   rundi: %d   (%s)",
                mark,
                g.title,
                item.solved,
                #g.levels,
                item.runs,
                g.rel
            )
        end,
    }, function(choice)
        if choice then
            open_game(choice.game.id)
        end
    end)
end

local function do_new_game(name)
    local clean = clean_player_name(name)
    if not clean then
        return
    end
    local buf = current_dojo()
    local game = (buf and ensure_game_for_buf(buf)) or active_game(buf)
    if buf and state.player and state.player ~= clean then
        local prev_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        save_progress(prev_lines, disk_sig_for(buf))
    end
    local rec = ensure_player_record(clean)
    rec.games[game.id] = make_empty_slot()
    apply_slot(clean, game.id)
    if buf then
        restore_buf(buf)
        state.seen_fp[buf] = nil
    end
    save_progress(false)
    if buf then
        refresh(buf, false)
        M.next()
    end
    vim.notify(string.format("New Game: '%s' — %s (0/%d).", clean, game.title, #game.levels), vim.log.levels.INFO)
end

function M.new_game(name)
    local clean = clean_player_name(name)
    if clean then
        do_new_game(clean)
        return
    end
    vim.ui.input({ prompt = "New Game — ime igraca: " }, function(input)
        local chosen = clean_player_name(input)
        if not chosen then
            return
        end
        do_new_game(chosen)
    end)
end

function M.save_game(name)
    local buf = current_dojo()
    if not buf then
        vim.notify("Otvori igru sa :DojoGames.", vim.log.levels.WARN)
        return
    end
    local game = ensure_game_for_buf(buf) or active_game(buf)
    local clean = clean_player_name(name)
    if clean then
        state.player = clean
    end
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local _, done_n = M.evaluate(lines, state, game.id)
    save_progress(lines, disk_sig_for(buf))
    vim.bo[buf].modified = false
    state.seen_fp[buf] = nil
    refresh(buf, false)
    vim.notify(
        string.format("Save Game: '%s' — %s (%d/%d) sacuvan.", state.player, game.title, done_n, #game.levels),
        vim.log.levels.INFO
    )
end

local function do_load_game(name)
    local clean = clean_player_name(name)
    if not clean then
        return
    end
    if type(state.players[clean]) ~= "table" then
        vim.notify(
            string.format("Igrac '%s' ne postoji. Pokreni :DojoNew %s", clean, clean),
            vim.log.levels.WARN
        )
        return
    end
    local buf = current_dojo()
    local game = (buf and ensure_game_for_buf(buf)) or active_game(buf)
    if buf and state.player and state.player ~= clean then
        local prev_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        save_progress(prev_lines, disk_sig_for(buf))
    end
    apply_slot(clean, game.id)
    write_store()
    if buf then
        if can_restore_saved_lines(buf) then
            apply_buffer_lines(buf, state.saved_lines)
        else
            restore_buf(buf)
        end
        state.seen_fp[buf] = nil
        refresh(buf, false)
        M.next()
    end
    local solved_n = count_solved({ solved = state.solved })
    vim.notify(
        string.format("Load Game: '%s' — %s (%d/%d, rundi: %d).", clean, game.title, solved_n, #game.levels, state.runs or 0),
        vim.log.levels.INFO
    )
end

function M.load_game(name)
    local clean = clean_player_name(name)
    if clean then
        do_load_game(clean)
        return
    end
    local buf = current_dojo()
    local game = (buf and ensure_game_for_buf(buf)) or active_game(buf)
    local names = sorted_player_names()
    local items = {}
    for _, n in ipairs(names) do
        items[#items + 1] = { kind = "player", name = n, slot = get_player_game_slot(n, game.id) }
    end
    items[#items + 1] = { kind = "new" }

    vim.ui.select(items, {
        prompt = string.format("Dojo (%s) — izaberi igraca:", game.title),
        format_item = function(item)
            if item.kind == "new" then
                return "+ New Game (novi igrac)..."
            end
            local mark = (item.name == state.player) and "* " or "  "
            local solved_n = count_solved(item.slot)
            local runs = tonumber(item.slot and item.slot.runs) or 0
            local when = (item.slot and item.slot.saved_at) or ""
            return string.format("%s%-14s %2d/%-2d   rundi: %d   %s", mark, item.name, solved_n, #game.levels, runs, when)
        end,
    }, function(choice)
        if not choice then
            return
        end
        if choice.kind == "new" then
            M.new_game()
        else
            do_load_game(choice.name)
        end
    end)
end

function M.delete_game(name)
    local function remove_player(target)
        local clean = clean_player_name(target)
        if not clean or type(state.players[clean]) ~= "table" then
            vim.notify(string.format("Igrac '%s' ne postoji.", tostring(target or "")), vim.log.levels.WARN)
            return
        end
        state.players[clean] = nil
        local buf = current_dojo()
        local game = active_game(buf)
        if state.player == clean then
            local remaining = sorted_player_names()
            local next_player = remaining[1] or "default"
            apply_slot(next_player, game.id)
            if buf then
                if can_restore_saved_lines(buf) then
                    apply_buffer_lines(buf, state.saved_lines)
                else
                    restore_buf(buf)
                end
                state.seen_fp[buf] = nil
                refresh(buf, false)
            end
        end
        write_store()
        vim.notify(string.format("Obrisan save za igraca '%s'.", clean), vim.log.levels.INFO)
    end

    local clean = clean_player_name(name)
    if clean then
        remove_player(clean)
        return
    end
    local names = sorted_player_names()
    if #names == 0 then
        vim.notify("Nema sacuvanih igraca.", vim.log.levels.INFO)
        return
    end
    vim.ui.select(names, {
        prompt = "Obrisi save igraca:",
    }, function(choice)
        if choice then
            remove_player(choice)
        end
    end)
end

function M.reset_level(target)
    local buf = current_dojo()
    if not buf then
        vim.notify("Otvori igru sa :DojoGames.", vim.log.levels.WARN)
        return
    end
    local game = ensure_game_for_buf(buf) or active_game(buf)
    local level_id = tonumber(target)
    if not level_id then
        if vim.api.nvim_get_current_buf() == buf then
            level_id = section_at(buf, vim.api.nvim_win_get_cursor(0)[1])
        end
    end
    if not level_id or level_id < 1 or level_id > #game.levels then
        vim.notify("Stani unutar nekog nivoa ili zadaj broj (npr. :DojoResetLevel 5).", vim.log.levels.WARN)
        return
    end

    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" then
        return
    end
    local disk_lines = vim.fn.readfile(name)
    local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local ds, de = level_range(disk_lines, level_id, game.comment)
    local bs, be = level_range(buf_lines, level_id, game.comment)
    if not ds or not bs then
        vim.notify(string.format("Nivo %02d nije pronadjen u fajlu.", level_id), vim.log.levels.WARN)
        return
    end

    local replacement = vim.list_slice(disk_lines, ds, de)
    local was = state.pausing[buf]
    state.pausing[buf] = true
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, bs - 1, be, false, replacement)
    state.pausing[buf] = was

    local prefix = string.format("%02d:", level_id)
    for key in pairs(state.actions) do
        if key:sub(1, #prefix) == prefix then
            state.actions[key] = nil
        end
    end
    if game.id == "core" then
        if level_id == 23 then
            state.harpoon_files = {}
        elseif level_id == 30 then
            state.ai_counts = {}
        end
    end
    state.solved[tostring(level_id)] = nil
    state.announced[level_id] = nil
    save_progress()

    state.seen_fp[buf] = nil
    refresh(buf, false)
    vim.notify(string.format("Nivo %02d je vracen na pocetak.", level_id), vim.log.levels.INFO)
end

function M.reset_all()
    local buf = current_dojo()
    if buf then
        ensure_game_for_buf(buf)
        restore_buf(buf)
        state.seen_fp[buf] = nil
    end
    clear_progress()
    if buf then
        refresh(buf, false)
    end
    vim.notify("Dojo je vracen na pocetak. Napredak i runde su obrisani.", vim.log.levels.INFO)
end

local function check_oil(buf)
    if not state.session or state.game ~= "core" then
        return
    end
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    local name = vim.api.nvim_buf_get_name(buf):gsub("\\", "/")
    local is_oil = vim.bo[buf].filetype == "oil" or name:match("^oil://") ~= nil
    if not is_oil then
        return
    end
    local changed = mark_action("22:oil")
    local dir = name:gsub("^oil://", "")
    local ok, oil = pcall(require, "oil")
    if ok and type(oil.get_current_dir) == "function" then
        local got = oil.get_current_dir(buf)
        if type(got) == "string" and got ~= "" then
            dir = got
        end
    end
    dir = dir:gsub("\\", "/"):gsub("/+$", "")
    if dir:match("lua/fikolis/lazy$") or dir:match("lua/fikolis/lazy/") then
        changed = mark_action("22:lazy") or changed
    end
    if changed then
        touch()
    end
end

function M.setup()
    if M._ready then
        return
    end
    M._ready = true
    GAMES.core = {
        id = "core",
        file = "learn_nvim.lua",
        rel = "learning/learn_nvim.lua",
        title = "Neovim Core (Lua)",
        comment = "%-%-",
        levels = LEVELS,
    }
    local yaml_levels = require("fikolis.learn_yaml_levels")
    local yaml_helpers = {
        play = function(lines, level)
            return play(lines, level, "#")
        end,
        oneline = oneline,
        ordered_lines = ordered_lines,
        count_plain = count_plain,
        code = code,
    }
    GAMES.k8s = {
        id = "k8s",
        file = "learn_k8s.yaml",
        rel = "learning/k8s/learn_k8s.yaml",
        title = "Kubernetes & OpenShift",
        comment = "#",
        levels = yaml_levels.k8s(yaml_helpers),
    }
    GAMES.ansible = {
        id = "ansible",
        file = "learn_ansible.yaml",
        rel = "learning/ansible/learn_ansible.yaml",
        title = "Ansible & RHEL 9",
        comment = "#",
        levels = yaml_levels.ansible(yaml_helpers),
    }
    load_progress()
    define_hl()

    local group = vim.api.nvim_create_augroup("LearnDojo", { clear = true })
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufWinEnter" }, {
        group = group,
        pattern = { "*learn_nvim.lua", "*learn_k8s.yaml", "*learn_ansible.yaml" },
        callback = function(ev)
            attach(ev.buf)
            if vim.b[ev.buf].learn_dojo then
                schedule_refresh(ev.buf, false)
            end
        end,
    })
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = define_hl,
    })
    vim.api.nvim_create_autocmd("ExitPre", {
        group = group,
        callback = function()
            for _, buf in ipairs(dojo_bufs()) do
                ensure_game_for_buf(buf)
                if not state.victory[buf] and vim.bo[buf].modified then
                    local cur_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                    save_progress(cur_lines, disk_sig_for(buf))
                end
                if vim.bo[buf].modified or vim.bo[buf].buftype == "acwrite" then
                    state.pausing[buf] = true
                    vim.bo[buf].modifiable = true
                    restore_buf(buf)
                    vim.bo[buf].modified = false
                end
            end
        end,
    })
    vim.api.nvim_create_autocmd("CmdlineLeave", {
        group = group,
        callback = function()
            if not state.session or state.game ~= "core" or not dojo_current() then
                return
            end
            local kind = vim.fn.getcmdtype()
            if kind ~= "/" and kind ~= "?" then
                return
            end
            local cmd = vim.fn.getcmdline() or ""
            if cmd:lower():find("ping_meta", 1, true) and mark_action("02:search") then
                touch()
            end
        end,
    })
    vim.api.nvim_create_autocmd("TextYankPost", {
        group = group,
        callback = function()
            if not state.session or state.game ~= "core" or not dojo_current() or section_now() ~= 8 then
                return
            end
            if vim.v.event.regname ~= "+" then
                return
            end
            local regtype = vim.v.event.regtype
            local id = (regtype == "V") and "08:line" or (regtype == "v" and "08:char" or nil)
            if id and mark_action(id) then
                touch()
            end
        end,
    })
    vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function(ev)
            if not state.session then
                return
            end
            if vim.b[ev.buf].learn_dojo then
                ensure_game_for_buf(ev.buf)
            end
            wrap_keymaps(ev.buf)
            local name = vim.api.nvim_buf_get_name(ev.buf):gsub("\\", "/")
            if state.game == "core" then
                if name:match("/ai%.lua$") or name:match("^ai%.lua$") then
                    if state.actions["20:pf"] and mark_action("20:ai") then
                        touch()
                    end
                end
                check_oil(ev.buf)
                if vim.b[ev.buf].learn_dojo == "core" and state.actions["22:oil"] and mark_action("22:back") then
                    touch()
                end
            end
        end,
    })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "oil",
        callback = function(ev)
            check_oil(ev.buf)
        end,
    })
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "OilEnter",
        callback = function()
            check_oil(vim.api.nvim_get_current_buf())
        end,
    })
    vim.api.nvim_create_autocmd({ "LspAttach" }, {
        group = group,
        callback = function(ev)
            if not state.session then
                return
            end
            vim.schedule(function()
                wrap_keymaps(ev.buf)
            end)
        end,
    })
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = { "VeryLazy", "LazyLoad" },
        callback = function()
            if not state.session then
                return
            end
            vim.schedule(function()
                wrap_keymaps(current_dojo())
            end)
        end,
    })

    local function complete_players(arg_lead)
        local out = {}
        for _, name in ipairs(sorted_player_names()) do
            if name:sub(1, #arg_lead) == arg_lead then
                out[#out + 1] = name
            end
        end
        return out
    end

    local function complete_games(arg_lead)
        local out = {}
        for _, gid in ipairs(GAMES_ORDER) do
            if gid:sub(1, #arg_lead) == arg_lead then
                out[#out + 1] = gid
            end
        end
        return out
    end

    vim.api.nvim_create_user_command("Dojo", M.status, { desc = "Learn dojo: status svih nivoa" })
    vim.api.nvim_create_user_command("DojoHint", M.hint, { desc = "Learn dojo: mnemonici/hintovi za trenutni nivo" })
    vim.api.nvim_create_user_command("DojoGames", function(opts)
        M.games(opts.args ~= "" and opts.args or nil)
    end, { nargs = "?", complete = complete_games, desc = "Learn dojo: izaberi igru (Lua Core / DevOps YAML)" })
    vim.api.nvim_create_user_command("DojoNext", M.next, { desc = "Learn dojo: skoci na prvi nedovrsen nivo" })
    vim.api.nvim_create_user_command("DojoNew", function(opts)
        M.new_game(opts.args ~= "" and opts.args or nil)
    end, { nargs = "?", complete = complete_players, desc = "Learn dojo: New Game (novi igrac ili reset)" })
    vim.api.nvim_create_user_command("DojoSave", function(opts)
        M.save_game(opts.args ~= "" and opts.args or nil)
    end, { nargs = "?", complete = complete_players, desc = "Learn dojo: Save Game (sacuvaj napredak i bafer)" })
    vim.api.nvim_create_user_command("DojoLoad", function(opts)
        M.load_game(opts.args ~= "" and opts.args or nil)
    end, { nargs = "?", complete = complete_players, desc = "Learn dojo: Load / Continue Game (izaberi igraca)" })
    vim.api.nvim_create_user_command("DojoContinue", function(opts)
        M.load_game(opts.args ~= "" and opts.args or nil)
    end, { nargs = "?", complete = complete_players, desc = "Learn dojo: nastavi igru (alias za :DojoLoad)" })
    vim.api.nvim_create_user_command("DojoDelete", function(opts)
        M.delete_game(opts.args ~= "" and opts.args or nil)
    end, { nargs = "?", complete = complete_players, desc = "Learn dojo: obrisi sacuvanog igraca" })
    vim.api.nvim_create_user_command("DojoReset", M.reset_text, { desc = "Learn dojo: vrati tekst sa diska" })
    vim.api.nvim_create_user_command("DojoResetLevel", function(opts)
        M.reset_level(opts.args ~= "" and opts.args or nil)
    end, { nargs = "?", desc = "Learn dojo: vrati trenutni ili zadati nivo na pocetak" })
    vim.api.nvim_create_user_command("DojoResetAll", M.reset_all, {
        desc = "Learn dojo: vrati tekst i obrisi napredak trenutnog igraca",
    })

    M._key_ns = vim.on_key(function(_, typed)
        if not state.session or typed == nil or typed == "" then
            return
        end
        local ok, token = pcall(norm_typed, typed)
        if not ok or not token then
            return
        end
        local mode_ok, mode = pcall(function()
            return vim.api.nvim_get_mode().mode
        end)
        if not mode_ok or not mode then
            return
        end
        pcall(handle, token, mode)
    end, vim.api.nvim_create_namespace("learn_dojo_onkey"))
end

M._play = play
M._press = handle
M._refresh = refresh

return M
