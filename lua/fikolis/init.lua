require("fikolis.remap")
require("fikolis.set")
require("fikolis.lazy_init")
require("fikolis.ai").setup()

local augroup = vim.api.nvim_create_augroup
local FikolisGroup = augroup("Fikolis", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = "templ",
    },
    pattern = {
        [".*/sysprep/.*%.ya?ml"] = "yaml.ansible",
        [".*ansible.*/.*%.ya?ml"] = "yaml.ansible",
        [".*ocp.*/.*%.ya?ml"] = "yaml.kubernetes",
        [".*/k8s/.*%.ya?ml"] = "yaml.kubernetes",
        [".*/kubernetes/.*%.ya?ml"] = "yaml.kubernetes",
    },
})

autocmd("TextYankPost", {
    group = yank_group,
    pattern = "*",
    callback = function()
        vim.hl.on_yank({
            higroup = "IncSearch",
            timeout = 40,
        })
    end,
})

autocmd("BufWritePre", {
    group = FikolisGroup,
    pattern = "*",
    callback = function()
        if not vim.bo.modifiable or vim.bo.filetype == "markdown" or vim.bo.filetype == "diff" then
            return
        end
        local view = vim.fn.winsaveview()
        vim.cmd([[keeppatterns %s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
})

autocmd("LspAttach", {
    group = FikolisGroup,
    callback = function(e)
        local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = e.buf, desc = desc })
        end
        map("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
        map("n", "K", vim.lsp.buf.hover, "LSP: Hover documentation")
        map("n", "<leader>vws", vim.lsp.buf.workspace_symbol, "LSP: Workspace symbol")
        map("n", "<leader>vd", vim.diagnostic.open_float, "LSP: Show diagnostic float")
        map("n", "<leader>vca", vim.lsp.buf.code_action, "LSP: Code action")
        map("n", "<leader>vrr", vim.lsp.buf.references, "LSP: References")
        map("n", "<leader>vrn", vim.lsp.buf.rename, "LSP: Rename symbol")
        map("i", "<C-h>", vim.lsp.buf.signature_help, "LSP: Signature help")
        map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "LSP: Previous diagnostic")
        map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "LSP: Next diagnostic")
    end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
