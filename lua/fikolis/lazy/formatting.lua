return {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    keys = {
        {
            "<leader>f",
            function()
                require("conform").format({ async = true, lsp_format = "fallback" })
            end,
            mode = { "n", "v" },
            desc = "Format buffer (Conform/LSP)",
        },
    },
    opts = {
        formatters_by_ft = {
            bash = { "shfmt" },
            go = { "gofmt" },
            hcl = { "terraform_fmt" },
            json = { "prettier" },
            jsonc = { "prettier" },
            lua = { "stylua" },
            markdown = { "prettier" },
            sh = { "shfmt" },
            terraform = { "terraform_fmt" },
            yaml = function(bufnr)
                if vim.bo[bufnr].filetype == "yaml.jinja" then
                    return {}
                end
                return { "yamlfmt" }
            end,
            ["yaml.ansible"] = { "yamlfmt" },
            ["yaml.kubernetes"] = { "yamlfmt" },
            ["yaml.jinja"] = {}, -- do not run yamlfmt on Jinja templates
        },
        default_format_opts = {
            lsp_format = "fallback",
        },
    },
}
