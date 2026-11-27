-- Fast, free AI inline Tab completion via supermaven-nvim.
-- First run: execute :SupermavenUseFree inside Neovim to activate the free tier.
-- Toggle on/off anytime with <leader>ct.
-- Automatically disabled on sensitive DevOps/Ansible/K8s files (secrets, vaults, .env, keys).
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
    if vim.bo[buf].buftype ~= "" then
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

    -- Check first 20 lines for Ansible Vault header or Kubernetes Secret manifests
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
        "supermaven-inc/supermaven-nvim",
        event = "InsertEnter",
        cmd = {
            "SupermavenStart",
            "SupermavenStop",
            "SupermavenRestart",
            "SupermavenToggle",
            "SupermavenStatus",
            "SupermavenUseFree",
            "SupermavenUsePro",
            "SupermavenLogout",
        },
        keys = {
            { "<leader>ct", "<cmd>SupermavenToggle<CR>", desc = "AI: Toggle Tab completion (Supermaven)" },
        },
        opts = {
            keymaps = {
                accept_suggestion = "<Tab>",
                clear_suggestion = "<C-]>",
                accept_word = "<C-j>",
            },
            ignore_filetypes = {
                oil = true,
                fugitive = true,
                gitcommit = true,
                snacks_picker_input = true,
                snacks_terminal = true,
                help = true,
                qf = true,
            },
            log_level = "off",
            disable_inline_completion = false,
            disable_keymaps = false,
            condition = function()
                return is_sensitive_buffer(0)
            end,
        },
        config = function(_, opts)
            require("supermaven-nvim").setup(opts)
            if is_sensitive_buffer(0) then
                require("supermaven-nvim.api").stop()
            end
        end,
    },
}
