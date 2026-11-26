-- Multi-provider AI inline Tab completion via minuet-ai.nvim.
-- Switch provider/model on demand with <leader>cm (Snacks picker), toggle with <leader>ct.
-- <Tab> accepts ghost text when visible, otherwise behaves as a normal <Tab>.
-- blink.cmp stays untouched on <C-n>/<C-p>/<C-y>.

local ignore_ft = {
    "oil",
    "fugitive",
    "gitcommit",
    "snacks_picker_input",
    "snacks_terminal",
    "help",
    "qf",
}

local providers = {
    {
        id = "grok",
        label = "Grok (xAI — grok-code-fast-1)",
        minuet_provider = "openai_compatible",
        env = "XAI_API_KEY",
    },
    {
        id = "claude",
        label = "Claude (Anthropic — claude-haiku-4-5)",
        minuet_provider = "claude",
        env = "ANTHROPIC_API_KEY",
    },
    {
        id = "gemini",
        label = "Gemini (Google — gemini-2.5-flash)",
        minuet_provider = "gemini",
        env = "GEMINI_API_KEY",
    },
    {
        id = "openai",
        label = "OpenAI (gpt-4.1-mini)",
        minuet_provider = "openai",
        env = "OPENAI_API_KEY",
    },
    {
        id = "ollama",
        label = "Ollama (local — qwen2.5-coder:7b)",
        minuet_provider = "openai_fim_compatible",
        env = nil,
    },
    {
        id = "off",
        label = "Off (disable AI Tab completion)",
        minuet_provider = nil,
        env = nil,
    },
}

local function has_key(env)
    if not env then
        return true
    end
    local val = vim.env[env]
    return val ~= nil and val ~= ""
end

local function detect_initial_provider()
    for _, p in ipairs(providers) do
        if p.env and has_key(p.env) then
            return p
        end
    end
    return nil
end

local active_id = nil

local function apply_to_loaded_buffers(enabled)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            local ft = vim.bo[buf].filetype
            if enabled and not vim.tbl_contains(ignore_ft, ft) and vim.bo[buf].buftype == "" then
                vim.b[buf].minuet_virtual_text_auto_trigger = true
            else
                vim.b[buf].minuet_virtual_text_auto_trigger = false
            end
        end
    end
end

local function set_auto_trigger(enabled)
    local minuet = require("minuet")
    minuet.config.virtualtext.auto_trigger_ft = enabled and { "*" } or {}
    require("minuet.virtualtext").setup()
    apply_to_loaded_buffers(enabled)
end

local function select_provider(choice)
    if not choice then
        return
    end

    if choice.id == "off" then
        active_id = "off"
        set_auto_trigger(false)
        local ok, vt = pcall(require, "minuet.virtualtext")
        if ok and vt.action and vt.action.dismiss then
            pcall(vt.action.dismiss)
        end
        vim.notify("AI Tab completion: OFF", vim.log.levels.INFO)
        return
    end

    if choice.env and not has_key(choice.env) then
        vim.notify(
            ("Missing %s — export it in your shell before using %s"):format(choice.env, choice.label),
            vim.log.levels.WARN
        )
        return
    end

    require("minuet").config.provider = choice.minuet_provider
    active_id = choice.id
    set_auto_trigger(true)
    vim.notify("AI Tab completion: " .. choice.label, vim.log.levels.INFO)
end

local function open_switcher()
    require("minuet")
    vim.ui.select(providers, {
        prompt = "AI Tab Completion Provider",
        format_item = function(item)
            local mark = (item.id == active_id) and "● " or "  "
            if item.id == "off" then
                return mark .. item.label
            end
            local status = item.env and (has_key(item.env) and " [key OK]" or (" [no " .. item.env .. "]")) or " [local]"
            return mark .. item.label .. status
        end,
    }, select_provider)
end

local function toggle_completion()
    local minuet = require("minuet")
    local is_on = minuet.config.virtualtext.auto_trigger_ft and #minuet.config.virtualtext.auto_trigger_ft > 0

    if is_on then
        set_auto_trigger(false)
        local ok, vt = pcall(require, "minuet.virtualtext")
        if ok and vt.action and vt.action.dismiss then
            pcall(vt.action.dismiss)
        end
        vim.notify("AI Tab completion: OFF", vim.log.levels.INFO)
    else
        if not active_id or active_id == "off" then
            local detected = detect_initial_provider()
            if not detected then
                open_switcher()
                return
            end
            minuet.config.provider = detected.minuet_provider
            active_id = detected.id
        end
        set_auto_trigger(true)
        vim.notify("AI Tab completion: ON (" .. active_id .. ")", vim.log.levels.INFO)
    end
end

return {
    {
        "milanglacier/minuet-ai.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "InsertEnter",
        cmd = "Minuet",
        keys = {
            { "<leader>cm", open_switcher, desc = "AI: Switch Tab completion model" },
            { "<leader>ct", toggle_completion, desc = "AI: Toggle Tab completion" },
        },
        config = function()
            local initial = detect_initial_provider()
            active_id = initial and initial.id or "off"

            require("minuet").setup({
                provider = initial and initial.minuet_provider or "openai_compatible",
                n_completions = 1,
                throttle = 600,
                debounce = 300,
                notify = "warn",
                virtualtext = {
                    auto_trigger_ft = initial and { "*" } or {},
                    auto_trigger_ignore_ft = ignore_ft,
                    keymap = {
                        -- <Tab> is bound below with safe fallback to normal <Tab>
                        accept = nil,
                        accept_line = "<A-a>",
                        accept_word = "<A-w>",
                        accept_n_lines = "<A-z>",
                        prev = "<A-[>",
                        next = "<A-]>",
                        dismiss = "<A-e>",
                    },
                },
                provider_options = {
                    openai_compatible = {
                        name = "xAI Grok",
                        end_point = "https://api.x.ai/v1/chat/completions",
                        api_key = "XAI_API_KEY",
                        model = "grok-code-fast-1",
                        stream = true,
                        optional = {
                            max_tokens = 256,
                            top_p = 0.9,
                        },
                    },
                    claude = {
                        api_key = "ANTHROPIC_API_KEY",
                        model = "claude-haiku-4-5",
                        max_tokens = 256,
                        stream = true,
                        optional = {
                            top_p = 0.9,
                        },
                    },
                    gemini = {
                        api_key = "GEMINI_API_KEY",
                        model = "gemini-2.5-flash",
                        stream = true,
                        optional = {
                            generationConfig = {
                                maxOutputTokens = 256,
                                topP = 0.9,
                            },
                        },
                    },
                    openai = {
                        api_key = "OPENAI_API_KEY",
                        model = "gpt-4.1-mini",
                        stream = true,
                        optional = {
                            max_tokens = 256,
                            top_p = 0.9,
                        },
                    },
                    openai_fim_compatible = {
                        name = "Ollama",
                        end_point = "http://localhost:11434/v1/completions",
                        api_key = "TERM",
                        model = "qwen2.5-coder:7b",
                        stream = true,
                        optional = {
                            max_tokens = 256,
                            top_p = 0.9,
                        },
                    },
                },
            })

            -- Since this plugin lazy-loads on InsertEnter, enable on already-open buffers too
            if initial then
                apply_to_loaded_buffers(true)
            end

            vim.keymap.set("i", "<Tab>", function()
                local vt = require("minuet.virtualtext")
                if vt.action.is_visible() then
                    vt.action.accept()
                    return
                end
                local tab = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
                vim.api.nvim_feedkeys(tab, "in", false)
            end, { silent = true, desc = "AI: Accept ghost text or Tab" })
        end,
    },
}
