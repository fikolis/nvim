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
            yaml = { "yamlfmt" },
            ["yaml.ansible"] = { "yamlfmt" },
            ["yaml.kubernetes"] = { "yamlfmt" },
        },
        default_format_opts = {
            lsp_format = "fallback",
        },
    },
}
