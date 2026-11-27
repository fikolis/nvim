local M = {}

local function resolve_cmd(cmd)
    if vim.fn.executable(cmd) == 1 then
        return { cmd }
    end
    local shell = vim.env.SHELL or "/bin/zsh"
    return { shell, "-ic", cmd }
end

local function toggle_ai(name, cmd)
    local cwd = vim.fn.getcwd()
    local project = vim.fn.fnamemodify(cwd, ":t")

    Snacks.terminal.toggle(resolve_cmd(cmd), {
        cwd = cwd,
        win = {
            position = "float",
            border = "rounded",
            width = 0.85,
            height = 0.85,
            title = (" %s (%s) "):format(name, project),
            title_pos = "center",
            keys = {
                hide_term = { "<C-q>", "hide", mode = { "t", "n" }, desc = "Hide AI float" },
                q = { "q", "hide", mode = "n", desc = "Hide AI float" },
            },
        },
    })
end

function M.setup()
    local tools = {
        { key = "<leader>ca", name = "agy", cmd = "agy" },
        { key = "<leader>cc", name = "claude", cmd = "claude" },
        { key = "<leader>cg", name = "grok", cmd = "grok" },
        { key = "<leader>co", name = "opencode", cmd = "opencode" },
        { key = "<leader>cx", name = "codex", cmd = "codex" },
    }

    for _, tool in ipairs(tools) do
        vim.keymap.set("n", tool.key, function()
            toggle_ai(tool.name, tool.cmd)
        end, { desc = ("AI: %s float"):format(tool.name) })
    end
end

return M
