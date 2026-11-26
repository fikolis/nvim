return {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
        {
            "<leader>zz",
            function()
                require("zen-mode").toggle({
                    window = {
                        width = 90,
                        options = {
                            wrap = false,
                            number = true,
                            relativenumber = true,
                        },
                    },
                })
            end,
            desc = "Zen Mode (width 90, numbers)",
        },
        {
            "<leader>zZ",
            function()
                require("zen-mode").toggle({
                    window = {
                        width = 80,
                        options = {
                            wrap = false,
                            number = false,
                            relativenumber = false,
                            colorcolumn = "0",
                        },
                    },
                })
            end,
            desc = "Zen Mode (width 80, minimal)",
        },
    },
}
