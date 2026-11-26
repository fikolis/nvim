return {
    {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        opts = {},
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "mason-org/mason.nvim", cmd = "Mason", opts = {} },
            "mason-org/mason-lspconfig.nvim",
            "saghen/blink.cmp",
            { "b0o/SchemaStore.nvim", lazy = true },
        },
        config = function()
            local capabilities = require("blink.cmp").get_lsp_capabilities()
            local schemastore = require("schemastore")

            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        workspace = {
                            checkThirdParty = false,
                            library = { vim.env.VIMRUNTIME },
                        },
                        diagnostics = {
                            globals = { "vim", "it", "describe", "before_each", "after_each" },
                        },
                    },
                },
            })

            vim.lsp.config("jsonls", {
                settings = {
                    json = {
                        schemas = schemastore.json.schemas(),
                        validate = { enable = true },
                    },
                },
            })

            vim.lsp.config("yamlls", {
                settings = {
                    yaml = {
                        schemaStore = { enable = false, url = "" },
                        schemas = schemastore.yaml.schemas(),
                        format = {
                            enable = true,
                            singleQuote = false,
                            bracketSpacing = true,
                            proseWrap = "preserve",
                        },
                        validate = true,
                        hover = true,
                        completion = true,
                        customTags = {
                            "!reference scalar",
                            "!Ref scalar",
                            "!GetAtt scalar",
                            "!Sub scalar",
                            "!Join sequence",
                            "!Split sequence",
                            "!Select scalar",
                            "!FindInMap sequence",
                            "!Base64 scalar",
                            "!Cidr sequence",
                            "!ImportValue scalar",
                            "!GetAZs scalar",
                        },
                    },
                },
            })

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "rust_analyzer",
                    "powershell_es",
                    "bashls",
                    "yamlls",
                    "ansiblels",
                    "terraformls",
                    "dockerls",
                    "jsonls",
                    "gopls",
                },
                automatic_enable = true,
            })

            vim.diagnostic.config({
                virtual_text = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = true,
                    header = "",
                    prefix = "",
                },
            })
        end,
    },
}
