# Neovim Config (`0.12+`)

Fast, keyboard-first Neovim configuration built for DevOps and software engineering — combining **ThePrimeagen's** minimal-friction motions with **Folke's** lazy-loaded Lua architecture.

- **Neovim:** `0.12+` (uses native `vim.lsp.config`, `nvim.undotree`, `nohlsearch`, `winborder`, `gc` comments, EditorConfig)
- **Startup:** `~32 ms` (`3 / 26` plugins loaded at boot via `lazy.nvim`)
- **Leader:** `<Space>` | **LocalLeader:** `\`

---

## Requirements

- **Neovim** `>= 0.12.0`
- **Git**, **curl**, **tar**, **unzip**, and a **C compiler** (`gcc`/`clang`)
- **`tree-sitter-cli`** (required by `nvim-treesitter` `main` branch to compile parsers)
- **Node.js / npm** (for Mason LSPs: `ansiblels`, `yamlls`, `bashls`, `dockerls`, `jsonls`)
- **`ripgrep`** (`rg`) and **`fd`** (for `Snacks.picker`)

### macOS (Homebrew)

```bash
brew install neovim tree-sitter-cli ripgrep fd lazygit stylua shfmt hadolint shellcheck yamllint yamlfmt
```

Optional DevOps tools: `terraform`, `ansible-lint` (via `pipx`), `prettier`, `tflint` (via `:MasonInstall tflint`).

### RHEL / Rocky / AlmaLinux (9+)

> **Note:** Default RHEL 9 repositories ship `glibc 2.34`, `nodejs:16` (EOL), and no Neovim `0.12+`. Prebuilt `tree-sitter-cli` binaries (from `npm` or GitHub releases) require `GLIBC_2.35+` / `GLIBC_2.39`, so `tree-sitter-cli` must be compiled locally with Cargo on RHEL 9.

1. **System packages + Node.js 22 (AppStream + EPEL):**

```bash
# Enable EPEL (RHEL 9; on Rocky/Alma you can run: sudo dnf install -y epel-release)
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

# Switch from default Node 16 to Node 22 (required by modern Mason LSPs)
sudo dnf module reset -y nodejs
sudo dnf module enable -y nodejs:22

# Core requirements for lazy.nvim, treesitter, Mason LSPs, and Snacks picker
sudo dnf install -y git gcc gcc-c++ make curl tar unzip gzip ripgrep fd-find nodejs npm python3 python3-pip
```

2. **Neovim `0.12+` (official Linux tarball, works over SSH without FUSE):**

```bash
curl -fsSLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm -f nvim-linux-x86_64.tar.gz
nvim --version
```

3. **`tree-sitter-cli` *(optional on RHEL 9 — skip if you don't want Rust; Neovim degrades gracefully and built-in Lua/Markdown/Vim parsers still work)***:

   If you want full Treesitter highlighting for YAML/Terraform/Bash/Dockerfile, compile `tree-sitter-cli` natively via Cargo for RHEL 9's `glibc 2.34`:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
cargo install --locked tree-sitter-cli
tree-sitter --version
```

*(Make sure `~/.cargo/bin` is in your `$PATH`, e.g. via `source "$HOME/.cargo/env"` in `~/.bashrc`.)*

4. **Optional DevOps / Ansible linters & formatters:**

```bash
# Ansible & YAML linting
pip3 install --user ansible-lint yamllint

# Shell linting (via EPEL)
sudo dnf install -y ShellCheck
```

Other formatters/linters (`stylua`, `shfmt`, `yamlfmt`, `hadolint`, `tflint`, `prettier`) can be installed directly inside Neovim via `:MasonInstall`. Everything in `nvim-lint` and `conform.nvim` degrades gracefully if a tool isn't installed.

---

## Installation

Back up any existing config, then clone into `~/.config/nvim`:

```bash
# SSH
git clone git@github.com:fikolis/nvim.git ~/.config/nvim

# Or HTTPS (handy on remote servers without SSH keys)
git clone https://github.com/fikolis/nvim.git ~/.config/nvim
```

Start Neovim (or sync plugins headlessly):

```bash
nvim --headless "+Lazy! sync" +qa
```

Open `nvim` and run `:checkhealth nvim-treesitter vim.treesitter mason` to verify parsers, LSPs, `blink.cmp`, `snacks`, and `which-key`.

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
    ├── ai.lua              # Persistent Snacks floating terminal launchers (agy, claude, grok, opencode, codex)
    ├── lazy_init.lua       # lazy.nvim bootstrap & performance config
    └── lazy/
        ├── ai_completion.lua # minuet-ai.nvim inline Tab completion + provider switcher
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

### AI CLI Floats (`Snacks.terminal`) & Inline Tab Completion (`minuet-ai.nvim`)
| Key | Action |
|---|---|
| `<leader>ca` | Toggle `agy` floating terminal |
| `<leader>cc` | Toggle `claude` floating terminal |
| `<leader>cg` | Toggle `grok` floating terminal |
| `<leader>co` | Toggle `opencode` floating terminal |
| `<leader>cx` | Toggle `codex` floating terminal |
| `<C-q>` *(in float)* | Hide AI float without stopping the session (`q` also hides in normal mode) |
| `<leader>cm` | Switch AI Tab completion provider (`Grok`, `Claude`, `Gemini`, `OpenAI`, `Ollama`, `Off`) |
| `<leader>ct` | Toggle AI Tab completion on/off |
| `<Tab>` *(insert)* | Accept AI ghost text (falls back to normal `<Tab>` when none is visible) |
| `<A-a>` / `<A-w>` *(insert)* | Accept AI suggestion line / word |
| `<A-]>` / `<A-[>` / `<A-e>` *(insert)* | Next / previous / dismiss AI suggestion |

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

- **Custom YAML & Template Filetypes** ([init.lua](lua/fikolis/init.lua)):
  - `*.y{a,}ml.j2` → `yaml.jinja` (`priority = 20`, excluded from `yamlls`, `yamlfmt`, and `yamllint`), `*.j2` → `jinja`
  - `*ocp*/*.y{a,}ml`, `*/k8s/*.y{a,}ml`, `*/kubernetes/*.y{a,}ml` → `yaml.kubernetes` (`priority = 10`, always wins over Ansible)
  - `*/sysprep/*`, `*ansible*/*`, standard Ansible dirs (`playbooks/`, `roles/*/tasks|handlers|vars|defaults/`, `group_vars/`, `host_vars/`), or any YAML under a project with `ansible.cfg`/`.ansible-lint` → `yaml.ansible`
- **2-Space Indentation** ([set.lua](lua/fikolis/set.lua)): auto-applied to `yaml`, `yaml.ansible`, `yaml.kubernetes`, `yaml.jinja`, `jinja`, `json`, `jsonc`, `terraform`, `hcl`, `helm`.
- **LSPs (Mason `ensure_installed`):** `lua_ls`, `rust_analyzer`, `powershell_es`, `bashls`, `yamlls` (+ `SchemaStore.nvim`, Kubernetes schema for `yaml.kubernetes`, CloudFormation/GitLab `!reference` custom tags), `ansiblels` (auto-detects working Python & `ansible-lint`), `terraformls` (`terraform`, `terraform-vars`, `hcl`), `dockerls`, `jsonls` (+ `SchemaStore.nvim`), `gopls`.
- **Formatters (`conform.nvim`):** `stylua`, `shfmt`, `yamlfmt`, `terraform_fmt`, `gofmt`, `prettier`.
- **Linters (`nvim-lint`):** `shellcheck`, `hadolint`, `tflint`, `yamllint` (`ansible-lint` runs directly via `ansiblels`).
