return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
        { "<leader>qq", "<cmd>Trouble diagnostics toggle<CR>", desc = "Trouble: Workspace diagnostics" },
        { "<leader>qb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Trouble: Buffer diagnostics" },
        { "<leader>qs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Trouble: Symbols" },
        { "<leader>qf", "<cmd>Trouble qflist toggle<CR>", desc = "Trouble: Quickfix list" },
        { "<leader>ql", "<cmd>Trouble loclist toggle<CR>", desc = "Trouble: Location list" },
    },
}
