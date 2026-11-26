return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
        local lint = require("lint")
        lint.linters_by_ft = {
            bash = { "shellcheck" },
            dockerfile = { "hadolint" },
            sh = { "shellcheck" },
            terraform = { "tflint" },
            yaml = { "yamllint" },
            ["yaml.ansible"] = {}, -- ansiblels already runs ansible-lint (which includes yamllint)
            ["yaml.jinja"] = {}, -- do not run yamllint on Jinja templates
        }

        local function try_lint_available()
            local names = lint._resolve_linter_by_ft(vim.bo.filetype)
            local available = {}
            for _, name in ipairs(names) do
                local linter = lint.linters[name]
                if linter then
                    local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
                    if cmd and vim.fn.executable(cmd) == 1 then
                        table.insert(available, name)
                    end
                end
            end
            if #available > 0 then
                lint.try_lint(available)
            end
        end

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = vim.api.nvim_create_augroup("FikolisLint", { clear = true }),
            callback = try_lint_available,
        })
    end,
}
