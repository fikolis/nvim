return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    build = ":TSUpdate",
    dependencies = {
        { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
    },
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "bash", "dockerfile", "go", "hcl", "json", "lua",
                "markdown", "markdown_inline", "python", "query",
                "rust", "terraform", "toml", "vim", "vimdoc", "yaml",
            },
            sync_install = false,
            auto_install = false,
            indent = { enable = true },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = { query = "@function.outer", desc = "Select outer function" },
                        ["if"] = { query = "@function.inner", desc = "Select inner function" },
                        ["ac"] = { query = "@class.outer", desc = "Select outer class" },
                        ["ic"] = { query = "@class.inner", desc = "Select inner class" },
                        ["aa"] = { query = "@parameter.outer", desc = "Select outer parameter" },
                        ["ia"] = { query = "@parameter.inner", desc = "Select inner parameter" },
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]f"] = { query = "@function.outer", desc = "Next function start" },
                        ["]c"] = { query = "@class.outer", desc = "Next class start" },
                    },
                    goto_previous_start = {
                        ["[f"] = { query = "@function.outer", desc = "Prev function start" },
                        ["[c"] = { query = "@class.outer", desc = "Prev class start" },
                    },
                },
            },
        })
    end,
}
