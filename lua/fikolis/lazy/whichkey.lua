return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "helix",
        spec = {
            { "<leader>g", group = "Git" },
            { "<leader>gh", group = "Git hunks" },
            { "<leader>l", group = "LSP" },
            { "<leader>p", group = "Find / Project" },
            { "<leader>q", group = "Trouble / Diagnostics" },
            { "<leader>v", group = "LSP actions" },
            { "<leader>w", group = "Which-Key" },
            { "<leader>z", group = "Zen Mode" },
        },
    },
    keys = {
        {
            "<leader>wk",
            function()
                require("which-key").show({ global = true })
            end,
            desc = "Which-Key: All keymaps",
        },
        {
            "<leader>w?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Which-Key: Buffer local keymaps",
        },
    },
}
