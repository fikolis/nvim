local function has_working_tree_sitter_cli()
    if vim.fn.executable("tree-sitter") ~= 1 then
        return false
    end
    local ok, res = pcall(function()
        return vim.system({ "tree-sitter", "--version" }):wait()
    end)
    return ok and res and res.code == 0
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = function()
            if has_working_tree_sitter_cli() then
                vim.cmd("TSUpdate")
            end
        end,
        config = function()
            local ts = require("nvim-treesitter")
            ts.setup({})

            local parsers = {
                "bash", "dockerfile", "go", "hcl", "json", "lua",
                "markdown", "markdown_inline", "python", "query",
                "rust", "terraform", "toml", "vim", "vimdoc", "yaml",
            }

            local installed = {}
            for _, lang in ipairs(ts.get_installed()) do
                installed[lang] = true
            end

            local missing = vim.tbl_filter(function(lang)
                return not installed[lang]
            end, parsers)

            if #missing > 0 and has_working_tree_sitter_cli() then
                ts.install(missing)
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("FikolisTreesitter", { clear = true }),
                callback = function(ev)
                    if pcall(vim.treesitter.start, ev.buf) and vim.bo[ev.buf].buftype == "" then
                        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    lookahead = true,
                },
                move = {
                    set_jumps = true,
                },
            })

            local select = require("nvim-treesitter-textobjects.select")
            local select_maps = {
                ["af"] = { "@function.outer", "Select outer function" },
                ["if"] = { "@function.inner", "Select inner function" },
                ["ac"] = { "@class.outer", "Select outer class" },
                ["ic"] = { "@class.inner", "Select inner class" },
                ["aa"] = { "@parameter.outer", "Select outer parameter" },
                ["ia"] = { "@parameter.inner", "Select inner parameter" },
            }
            for lhs, spec in pairs(select_maps) do
                vim.keymap.set({ "x", "o" }, lhs, function()
                    select.select_textobject(spec[1], "textobjects")
                end, { desc = spec[2] })
            end

            local move = require("nvim-treesitter-textobjects.move")
            local move_next = {
                ["]f"] = { "@function.outer", "Next function start" },
                ["]c"] = { "@class.outer", "Next class start" },
            }
            for lhs, spec in pairs(move_next) do
                vim.keymap.set({ "n", "x", "o" }, lhs, function()
                    move.goto_next_start(spec[1], "textobjects")
                end, { desc = spec[2] })
            end

            local move_prev = {
                ["[f"] = { "@function.outer", "Prev function start" },
                ["[c"] = { "@class.outer", "Prev class start" },
            }
            for lhs, spec in pairs(move_prev) do
                vim.keymap.set({ "n", "x", "o" }, lhs, function()
                    move.goto_previous_start(spec[1], "textobjects")
                end, { desc = spec[2] })
            end
        end,
    },
}
