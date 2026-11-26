return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "powershell_es",
                "bashls",
                "yamlls",
                "ansiblels",
            },
            handlers = {
                function(server_name) -- default handler (optional)

                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,

                ["yamlls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.yamlls.setup {
                        capabilities = capabilities,
                        settings = {
                            yaml = {
                                schemas = {
                                    ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*.{yml,yaml}",
                                    ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.{yml,yaml}",
                                    ["https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/data/.ansible-lint-ignore.yaml"] = "**/.ansible-lint*",
                                    ["https://raw.githubusercontent.com/ansible/schemas/main/ansible.json"] = "**/*ansible*/**/*.{yml,yaml}",
                                    ["https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/v3/api__v1_openapi.json"] = "**/k8s/**/*.{yml,yaml}",
                                    ["https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/v3/apis__apps__v1_openapi.json"] = "**/k8s/**/*.{yml,yaml}",
                                },
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
                                    ["!reference"] = "scalar",
                                    ["!Ref"] = "scalar",
                                    ["!GetAtt"] = "scalar",
                                    ["!Sub"] = "scalar",
                                    ["!Join"] = "sequence",
                                    ["!Split"] = "sequence",
                                    ["!Select"] = "scalar",
                                    ["!FindInMap"] = "sequence",
                                    ["!Base64"] = "scalar",
                                    ["!Cidr"] = "sequence",
                                    ["!ImportValue"] = "scalar",
                                    ["!GetAZs"] = "scalar",
                                },
                            }
                        }
                    }
                end,
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
