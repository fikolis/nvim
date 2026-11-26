return {
    "theprimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },

    keys = {
        { "<leader>a", function() require("harpoon"):list():add() end, desc = "Harpoon: Add file" },
        { "<C-e>", function() local h = require("harpoon") h.ui:toggle_quick_menu(h:list()) end, desc = "Harpoon: Quick menu" },
        { "<C-j>", function() require("harpoon"):list():select(1) end, desc = "Harpoon: File 1" },
        { "<C-k>", function() require("harpoon"):list():select(2) end, desc = "Harpoon: File 2" },
        { "<C-h>", function() require("harpoon"):list():select(3) end, desc = "Harpoon: File 3" },
        { "<C-l>", function() require("harpoon"):list():select(4) end, desc = "Harpoon: File 4" },
        { "<C-S-P>", function() require("harpoon"):list():prev() end, desc = "Harpoon: Previous file" },
        { "<C-S-N>", function() require("harpoon"):list():next() end, desc = "Harpoon: Next file" },
    },
    config = function()
        require("harpoon"):setup()
    end,
}


