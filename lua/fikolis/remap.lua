vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw explorer" })
vim.keymap.set("n", "<leader>pp", vim.cmd.Lex, { desc = "Open netrw left explorer" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- tmux sessionizer
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Tmux sessionizer" })
vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>", { desc = "Tmux session 0" })
vim.keymap.set("n", "<M-t>", "<cmd>silent !tmux neww tmux-sessionizer -s 1<CR>", { desc = "Tmux session 1" })
vim.keymap.set("n", "<M-n>", "<cmd>silent !tmux neww tmux-sessionizer -s 2<CR>", { desc = "Tmux session 2" })
vim.keymap.set("n", "<M-s>", "<cmd>silent !tmux neww tmux-sessionizer -s 3<CR>", { desc = "Tmux session 3" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join line keeping cursor" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half-page down centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half-page up centered" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search match centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search match centered" })

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to void register" })

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Exit insert mode" })

vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Ex mode" })

vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Location list next centered" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Location list prev centered" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>", { desc = "Make it rain" })

vim.keymap.set("n", "<leader><leader>", function()
    if vim.bo.filetype == "lua" or vim.bo.filetype == "vim" then
        vim.cmd.source("%")
    end
end, { desc = "Source current Lua/Vim file" })

vim.keymap.set("n", "<leader>lr", "<cmd>lsp restart<CR>", { desc = "Restart LSP for current buffer" })

vim.keymap.set("n", "<leader>u", function()
    vim.cmd.packadd("nvim.undotree")
    require("undotree").open()
end, { desc = "Toggle Undotree" })

