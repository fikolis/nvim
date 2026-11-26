return {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
    keys = {
        { "<leader>gs", "<cmd>Git<CR>", desc = "Git: Status (Fugitive)" },
        { "<leader>gb", ":Git checkout -b ", desc = "Git: Checkout new branch" },
        { "<leader>g2", "<cmd>diffget //2<CR>", desc = "Git: Diffget ours (//2)" },
        { "<leader>g3", "<cmd>diffget //3<CR>", desc = "Git: Diffget theirs (//3)" },
    },
    config = function()
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("FikolisFugitive", { clear = true }),
            pattern = "fugitive",
            callback = function(ev)
                local opts = function(desc)
                    return { buffer = ev.buf, remap = false, desc = desc }
                end
                vim.keymap.set("n", "<leader>p", function()
                    vim.cmd.Git("push")
                end, opts("Git: Push"))
                vim.keymap.set("n", "<leader>P", function()
                    vim.cmd.Git("pull --rebase")
                end, opts("Git: Pull --rebase"))
                vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts("Git: Push and set upstream"))
            end,
        })
    end,
}
