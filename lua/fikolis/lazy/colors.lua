function ColorMyPencils(color)
    color = color or "rose-pine"
    vim.cmd.colorscheme(color)

    for _, group in ipairs({ "Normal", "NormalFloat" }) do
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        hl.bg = nil
        hl.ctermbg = nil
        vim.api.nvim_set_hl(0, group, hl)
    end
end

return {
    {
        "folke/tokyonight.nvim",
        lazy = true,
        opts = {
            style = "storm",
            transparent = true,
            terminal_colors = true,
            styles = {
                comments = { italic = false },
                keywords = { italic = false },
                sidebars = "dark",
                floats = "dark",
            },
        },
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = false,
        priority = 1000,
        config = function()
            require("rose-pine").setup({
                styles = { transparency = true },
            })

            ColorMyPencils()
        end,
    },
}
