-- Free AI inline Tab completion via Exafunction/windsurf.nvim (Codeium).
-- First run: execute :Codeium Auth inside Neovim and paste your free Windsurf token.
-- Toggle on/off anytime with <leader>ct.
-- Automatically disabled on sensitive DevOps/Ansible/K8s files (secrets, vaults, .env, keys),
-- and filtered out from cross-buffer context as well.
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
        "Exafunction/windsurf.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "InsertEnter",
        cmd = "Codeium",
        keys = {
            { "<leader>ct", "<cmd>Codeium Toggle<CR>", desc = "AI: Toggle Tab completion (Windsurf)" },
        },
        opts = {
            enable_cmp_source = false,
            enable_chat = false,
            enable_local_search = false,
            enable_index_service = false,
            virtual_text = {
                enabled = true,
                default_filetype_enabled = true,
                filetypes = {
                    oil = false,
                    fugitive = false,
                    gitcommit = false,
                    snacks_picker_input = false,
                    snacks_terminal = false,
                    help = false,
                    qf = false,
                },
                idle_delay = 75,
                map_keys = true,
                key_bindings = {
                    accept = "<Tab>",
                    accept_word = "<C-j>",
                    accept_line = "<A-a>",
                    clear = "<C-]>",
                    next = "<A-]>",
                    prev = "<A-[>",
                },
            },
        },
        config = function(_, opts)
            require("codeium").setup(opts)

            local vt = require("codeium.virtual_text")
            -- Since we lazy-load on InsertEnter (after ColorScheme/VimEnter), set ghost-text highlight now
            vt.set_style()

            -- Block completions on sensitive buffers
            local orig_ft_enabled = vt.filetype_enabled
            vt.filetype_enabled = function(bufnr)
                if is_sensitive_buffer(bufnr) then
                    return false
                end
                return orig_ft_enabled(bufnr)
            end

            -- Also prevent sensitive open buffers from being sent as cross-buffer context
            local util = require("codeium.util")
            local orig_other_docs = util.get_other_documents
            util.get_other_documents = function(bufnr)
                local blocked = {}
                for _, b in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_loaded(b) and is_sensitive_buffer(b) then
                        blocked[util.get_uri(vim.api.nvim_buf_get_name(b))] = true
                    end
                end
                local docs = orig_other_docs(bufnr)
                return vim.tbl_filter(function(doc)
                    return not blocked[doc.absolute_uri]
                end, docs)
            end
        end,
    },
}
