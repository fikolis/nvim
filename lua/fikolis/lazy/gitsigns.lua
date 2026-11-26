return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        on_attach = function(bufnr)
            local gs = require("gitsigns")
            local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end

            map("n", "]h", function() gs.nav_hunk("next") end, "Git: Next hunk")
            map("n", "[h", function() gs.nav_hunk("prev") end, "Git: Previous hunk")
            map("n", "<leader>ghs", gs.stage_hunk, "Git: Stage hunk")
            map("n", "<leader>ghr", gs.reset_hunk, "Git: Reset hunk")
            map("v", "<leader>ghs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Git: Stage hunk")
            map("v", "<leader>ghr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Git: Reset hunk")
            map("n", "<leader>ghp", gs.preview_hunk, "Git: Preview hunk")
            map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Git: Blame line")
            map("n", "<leader>ghd", gs.diffthis, "Git: Diff this")
        end,
    },
}
