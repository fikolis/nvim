-- Free AI inline Tab completion via zbirenbaum/copilot.lua (GitHub Copilot Free: 2,000/month).
-- First run: enable Copilot Free in GitHub settings, then run :Copilot auth inside Neovim.
-- Toggle on/off anytime with <leader>ct.
-- Never attaches to sensitive DevOps/Ansible/K8s files (secrets, vaults, .env, keys).
-- blink.cmp stays untouched on <C-n>/<C-p>/<C-y>.

local sensitive_patterns = {
    "[/\\]%.env$",
    "[/\\]%.env%.",
    "secret",
    "vault",
    "credential",
    "kubeconfig",
    "[/\\]%.kube[/\\]config$",
    "%.pem$",
    "%.key$",
    "%.p12$",
    "%.pfx$",
    "%.jks$",
    "%.tfvars$",
    "%.sops%.",
    "[/\\]id_rsa",
    "[/\\]id_ed25519",
}

local function is_sensitive_buffer(buf)
    buf = buf or 0
    if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then
        return true
    end

    local path = vim.api.nvim_buf_get_name(buf):lower()
    if path ~= "" then
        for _, pat in ipairs(sensitive_patterns) do
            if path:find(pat) then
                return true
            end
        end
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, 20, false)
    if lines[1] and lines[1]:find("^%$ANSIBLE_VAULT;") then
        return true
    end
    for _, line in ipairs(lines) do
        if line:find("^%s*kind:%s*Secret%s*$") then
            return true
        end
    end

    return false
end

return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        keys = {
            {
                "<leader>ct",
                function()
                    require("copilot.suggestion").toggle_auto_trigger()
                    local state = vim.b.copilot_suggestion_auto_trigger
                    vim.notify("Copilot Tab completion: " .. (state and "ON" or "OFF"), vim.log.levels.INFO)
                end,
                desc = "AI: Toggle Tab completion (Copilot)",
            },
        },
        opts = {
            panel = { enabled = false },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                hide_during_completion = true,
                debounce = 75,
                keymap = {
                    -- <Tab> is mapped below with safe fallback to normal <Tab>
                    accept = false,
                    accept_word = "<C-j>",
                    accept_line = "<A-a>",
                    next = "<A-]>",
                    prev = "<A-[>",
                    dismiss = "<C-]>",
                },
            },
            filetypes = {
                yaml = true,
                markdown = true,
                oil = false,
                fugitive = false,
                gitcommit = false,
                gitrebase = false,
                help = false,
                qf = false,
                snacks_picker_input = false,
                snacks_terminal = false,
                ["."] = false,
                ["*"] = true,
            },
            should_attach = function(bufnr, _)
                if not vim.bo[bufnr].buflisted or vim.bo[bufnr].buftype ~= "" then
                    return false
                end
                return not is_sensitive_buffer(bufnr)
            end,
        },
        config = function(_, opts)
            require("copilot").setup(opts)

            vim.keymap.set("i", "<Tab>", function()
                local suggestion = require("copilot.suggestion")
                if suggestion.is_visible() then
                    suggestion.accept()
                    return
                end
                local tab = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
                vim.api.nvim_feedkeys(tab, "in", false)
            end, { silent = true, desc = "AI: Accept Copilot suggestion or Tab" })
        end,
    },
}
