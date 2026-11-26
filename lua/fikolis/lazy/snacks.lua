return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = { enabled = true },
        input = { enabled = true },
        notifier = { enabled = true },
        picker = { enabled = true, ui_select = true },
        quickfile = { enabled = true },
        terminal = { enabled = true },
        words = { enabled = true },
    },
    keys = {
        { "<leader>pf", function() Snacks.picker.files() end, desc = "Find files" },
        { "<C-p>", function() Snacks.picker.git_files() end, desc = "Find git files" },
        { "<leader>ps", function() Snacks.picker.grep() end, desc = "Live grep" },
        { "<leader>pws", function() Snacks.picker.grep_word() end, mode = { "n", "x" }, desc = "Grep word under cursor" },
        {
            "<leader>pWs",
            function()
                Snacks.picker.grep({ search = vim.fn.expand("<cWORD>") })
            end,
            desc = "Grep WORD under cursor",
        },
        { "<leader>pb", function() Snacks.picker.buffers() end, desc = "Find buffers" },
        { "<leader>pd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
        { "<leader>vh", function() Snacks.picker.help() end, desc = "Help tags" },
        { "<leader>?", function() Snacks.picker.keymaps() end, desc = "Search all keymaps (cheatsheet)" },
        { "<leader>gl", function() Snacks.lazygit() end, desc = "Git: Lazygit" },
    },
}
