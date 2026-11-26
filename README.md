# Neovim Config (`0.12+`)

Fast, keyboard-first Neovim configuration built for DevOps and software engineering — combining **ThePrimeagen's** minimal-friction motions with **Folke's** lazy-loaded Lua architecture.

- **Neovim:** `0.12+` (uses native `vim.lsp.config`, `nvim.undotree`, `nohlsearch`, `winborder`, `gc` comments, EditorConfig)
- **Startup:** `~32 ms` (`3 / 26` plugins loaded at boot via `lazy.nvim`)
- **Leader:** `<Space>` | **LocalLeader:** `\`

---

## Requirements

- **Neovim** `>= 0.12.0`
- **Git** & a **C compiler** (`cc`/`clang` for Treesitter parsers)
- Recommended CLI tools (macOS / Homebrew):

```bash
brew install neovim ripgrep fd lazygit stylua shfmt hadolint shellcheck yamllint yamlfmt
```

Optional DevOps tools: `terraform`, `ansible-lint` (via `pipx`), `prettier`, `tflint` (via `:MasonInstall tflint`).

---

## Installation

Back up any existing config, then clone into `~/.config/nvim`:

```bash
git clone -b nvim-reconfigure-26 git@github.com:fikolis/nvim.git ~/.config/nvim
```

Start Neovim (or sync plugins headlessly):

```bash
nvim --headless "+Lazy! sync" +qa
```

Run `:checkhealth` inside Neovim to verify LSP, `blink.cmp`, `snacks`, `which-key`, and `mason`.

---

## Structure

```text
~/.config/nvim/
├── init.lua
├── lazy-lock.json
└── lua/fikolis/
    ├── init.lua            # Core autocmds, DevOps YAML filetypes, LspAttach keymaps
    ├── set.lua             # Editor options, 0.12 winborder/nohlsearch, 2-space DevOps indent
    ├── remap.lua           # Core motions, clipboard, tmux-sessionizer, builtin undotree
    ├── ai.lua              # Persistent Snacks floating terminal launchers (agy, grok, opencode, codex)
    ├── lazy_init.lua       # lazy.nvim bootstrap & performance config
    └── lazy/
        ├── colors.lua      # rose-pine (transparent) + tokyonight (lazy)
        ├── completion.lua  # blink.cmp + friendly-snippets
        ├── formatting.lua  # conform.nvim
        ├── fugitive.lua    # vim-fugitive
        ├── gitsigns.lua    # gitsigns.nvim
        ├── harpoon.lua     # harpoon2
        ├── init.lua        # plenary, cellular-automaton, golf
        ├── linting.lua     # nvim-lint
        ├── lsp.lua         # nvim-lspconfig, mason v2, SchemaStore.nvim, fidget.nvim
        ├── oil.lua         # oil.nvim
        ├── snacks.lua      # snacks.nvim (picker, terminal, lazygit, notifier, input, bigfile, words)
        ├── surround.lua    # nvim-surround
        ├── treesitter.lua  # nvim-treesitter + nvim-treesitter-textobjects
        ├── trouble.lua     # trouble.nvim
        ├── whichkey.lua    # which-key.nvim
        └── zenmode.lua     # zen-mode.nvim
```

---

## Keymaps

Press **`<leader>?`** at any time for a live fuzzy-searchable list of **all** keymaps, or **`<leader>wk`** for a categorized `which-key` popup.

### Cheatsheet & Discovery
| Key | Action |
|---|---|
| `<leader>?` | Search all keymaps (`Snacks.picker.keymaps`) |
| `<leader>wk` | Show all keymaps grouped (`which-key`) |
| `<leader>w?` | Show buffer-local keymaps (`which-key`) |
| `<leader>vh` | Search Neovim help tags |

### Find & Picker (`snacks.nvim`)
| Key | Action |
|---|---|
| `<leader>pf` | Find files |
| `<C-p>` | Find Git files |
| `<leader>ps` | Live grep across workspace |
| `<leader>pws` | Grep word under cursor (`n`, `x`) |
| `<leader>pWs` | Grep `WORD` under cursor |
| `<leader>pb` | Switch buffers |
| `<leader>pd` | Search diagnostics |

### Navigation & Files
| Key | Action |
|---|---|
| `-` | Open parent directory (`oil.nvim`) |
| `<leader>pv` / `<leader>pp` | Open `netrw` (`:Ex` / `:Lex`) |
| `<leader>a` | Harpoon: add current file |
| `<C-e>` | Harpoon: toggle quick menu |
| `<C-j>` / `<C-k>` / `<C-h>` / `<C-l>` | Harpoon: jump to file 1 / 2 / 3 / 4 |
| `<C-S-P>` / `<C-S-N>` | Harpoon: previous / next file |

### LSP, Formatting & Diagnostics
| Key | Action |
|---|---|
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<leader>vws` | Workspace symbols |
| `<leader>vrr` | References |
| `<leader>vrn` | Rename symbol |
| `<leader>vca` | Code action |
| `<leader>vd` | Show diagnostic float |
| `[d` / `]d` | Previous / next diagnostic (with float) |
| `<C-h>` *(insert)* | Signature help |
| `<leader>f` | Format buffer (`conform.nvim` with LSP fallback) |
| `<leader>lr` | Restart LSP for current buffer (`:lsp restart`) |
| `<leader>qq` / `<leader>qb` | Trouble: workspace / buffer diagnostics |
| `<leader>qs` | Trouble: document symbols |
| `<leader>qf` / `<leader>ql` | Trouble: quickfix / location list |

### Completion (`blink.cmp`)
| Key | Action |
|---|---|
| `<C-n>` / `<C-p>` | Next / previous item |
| `<C-y>` | Confirm selection |
| `<C-Space>` | Trigger completion menu |

### Git (`lazygit`, `vim-fugitive`, `gitsigns`)
| Key | Action |
|---|---|
| `<leader>gl` | Open Lazygit |
| `<leader>gs` | Fugitive `:Git` status |
| `<leader>gb` | `:Git checkout -b ` |
| `<leader>g2` / `<leader>g3` | 3-way merge diffget ours (`//2`) / theirs (`//3`) |
| `<leader>p` / `<leader>P` / `<leader>t` | *(In Fugitive)* Push / Pull `--rebase` / Push `-u origin` |
| `]h` / `[h` | Next / previous Git hunk |
| `<leader>ghs` / `<leader>ghr` | Stage / reset hunk (`n`, `v`) |
| `<leader>ghp` / `<leader>ghb` / `<leader>ghd` | Preview hunk / Blame line / Diff this |

### Editing, Motions & Textobjects
| Key | Action |
|---|---|
| `J` / `K` *(visual)* | Move selected lines down / up |
| `<leader>p` *(visual)* | Paste without overwriting yank register |
| `<leader>y` / `<leader>Y` | Yank to system clipboard |
| `<leader>d` | Delete to void register |
| `<leader>s` | Search & replace word under cursor |
| `<leader>u` | Toggle built-in Neovim `0.12` Undotree |
| `af`/`if`, `ac`/`ic`, `aa`/`ia` | Treesitter select function / class / parameter |
| `]f` / `[f`, `]c` / `[c` | Jump to next / previous function or class |
| `ys`, `cs`, `ds` | Surround add / change / delete (`nvim-surround`) |
| `gc` / `gcc` | Built-in comment operator / line |

### AI CLI Floats (`Snacks.terminal`)
| Key | Action |
|---|---|
| `<leader>ca` | Toggle `agy` floating terminal |
| `<leader>cg` | Toggle `grok` floating terminal |
| `<leader>co` | Toggle `opencode` floating terminal |
| `<leader>cx` | Toggle `codex` floating terminal |
| `<C-q>` *(in float)* | Hide AI float without stopping the session (`q` also hides in normal mode) |

### Tmux & Utilities
| Key | Action |
|---|---|
| `<C-f>` | `tmux-sessionizer` |
| `<M-h>` / `<M-t>` / `<M-n>` / `<M-s>` | `tmux-sessionizer -s 0..3` |
| `<leader>zz` / `<leader>zZ` | Zen Mode (width 90 with numbers / width 80 minimal) |
| `<leader>x` | `chmod +x` current file |
| `<leader><leader>` | Source current `.lua` / `.vim` file |
| `<leader>mr` | Cellular Automaton `make_it_rain` |

---

## DevOps Language Support

- **Custom YAML Filetypes** ([init.lua](lua/fikolis/init.lua)):
  - `*/sysprep/*.y{a,}ml`, `*ansible*/*.y{a,}ml` → `yaml.ansible`
  - `*ocp*/*.y{a,}ml`, `*/k8s/*.y{a,}ml`, `*/kubernetes/*.y{a,}ml` → `yaml.kubernetes`
- **2-Space Indentation** ([set.lua](lua/fikolis/set.lua)): auto-applied to `yaml`, `yaml.ansible`, `yaml.kubernetes`, `json`, `jsonc`, `terraform`, `hcl`, `helm`.
- **LSPs (Mason `ensure_installed`):** `lua_ls`, `rust_analyzer`, `powershell_es`, `bashls`, `yamlls` (+ `SchemaStore.nvim` & CloudFormation/GitLab `!reference` custom tags), `ansiblels`, `terraformls`, `dockerls`, `jsonls` (+ `SchemaStore.nvim`), `gopls`.
- **Formatters (`conform.nvim`):** `stylua`, `shfmt`, `yamlfmt`, `terraform_fmt`, `gofmt`, `prettier`.
- **Linters (`nvim-lint`):** `shellcheck`, `hadolint`, `tflint`, `yamllint`, `ansible-lint` (only runs when executable is installed on `PATH`).
