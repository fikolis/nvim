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

            local function find_working_executable(name)
                local sep = vim.fn.has("win32") == 1 and ";" or ":"
                for _, dir in ipairs(vim.split(vim.env.PATH or "", sep, { trimempty = true })) do
                    local candidate = dir .. "/" .. name
                    if vim.fn.executable(candidate) == 1 then
                        local ok, lines = pcall(vim.fn.readfile, candidate, "", 1)
                        local shebang = ok and lines[1] and lines[1]:match("^#!%s*(%S+)")
                        if not shebang or vim.fn.executable(shebang) == 1 then
                            return candidate
                        end
                    end
                end
                return nil
            end

            local function ansible_python()
                local ansible_bin = find_working_executable("ansible")
                if ansible_bin then
                    local ok, lines = pcall(vim.fn.readfile, ansible_bin, "", 1)
                    if ok and lines[1] then
                        local shebang_py = lines[1]:match("^#!%s*(%S+)")
                        if shebang_py and not shebang_py:match("env$") and vim.fn.executable(shebang_py) == 1 then
                            return shebang_py
                        end
                    end
                end
                return vim.fn.executable("python3") == 1 and "python3" or "python"
            end

            local ansible_lint_bin = find_working_executable("ansible-lint")

            vim.lsp.config("yamlls", {
                filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values", "yaml.kubernetes" },
                settings = {
                    yaml = {
                        schemaStore = { enable = false, url = "" },
                        schemas = vim.tbl_extend("force", schemastore.yaml.schemas(), {
                            kubernetes = {
                                "**/k8s/**/*.{yml,yaml}",
                                "**/kubernetes/**/*.{yml,yaml}",
                                "**/*ocp*/**/*.{yml,yaml}",
                            },
                        }),
                        format = { enable = false },
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

            vim.lsp.config("ansiblels", {
                settings = {
                    ansible = {
                        ansible = { path = "ansible" },
                        executionEnvironment = { enabled = false },
                        python = { interpreterPath = ansible_python() },
                        validation = {
                            enabled = true,
                            lint = {
                                enabled = ansible_lint_bin ~= nil,
                                path = ansible_lint_bin or "ansible-lint",
                            },
                        },
                    },
                },
            })

            vim.lsp.config("terraformls", {
                filetypes = { "terraform", "terraform-vars", "hcl" },
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
