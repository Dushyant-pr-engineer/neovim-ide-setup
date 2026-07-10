# Your Neovim IDE Setup — Verified & Tailored Plan

Built for: PHP, JS/TS, Go, Python, + Markdown/Shell/YAML/JSON/Terraform, using Claude Code and Git, on Apple Silicon.

## What I checked, and what I changed from your attached plan

Your attached plan is a solid skeleton (Alacritty + Zsh + Tmux + lazy.nvim, single Lua config location) and I kept that overall shape. But I verified every command and API against current sources, and several things in it are **outdated or would fail as written**, and a few important gaps existed for your specific stack:

| Issue in original plan | Why it's a problem | Fix in this plan |
|---|---|---|
| `brew tap homebrew/cask-fonts` | This tap was deprecated in May 2024 — all fonts moved into the main `homebrew/cask` tap. The command now errors out. | Just `brew install --cask font-jetbrains-mono-nerd-font`, no tap needed. |
| `require("mason-lspconfig").setup_handlers{...}` + `require('lspconfig')...setup{}` pattern | This is the **legacy** lspconfig "framework," which is deprecated as of Neovim 0.11+ (your Nov 2026 Neovim will be well past that). `require('lspconfig')` calls now emit a warning and will eventually error. | Use the native `vim.lsp.config()` / `vim.lsp.enable()` API, with `mason-lspconfig.nvim`'s new `automatic_enable` behavior. |
| `nvim-cmp` for completion | Still works, but it's now the "legacy" completion engine. Community (including kickstart.nvim) has largely moved to `blink.cmp` — faster (sub-ms vs ~60ms debounce) and simpler to configure. | Swapped in `blink.cmp`. |
| No PHP, Composer, or Terraform CLI installed | You listed PHP as your **first** language, but the plan never installs PHP or Composer — only `intelephense` is configured, which needs `composer.json` as a root marker and a working PHP install to be useful. Terraform LSP was configured but the `terraform` binary itself wasn't installed. | Added both. |
| No formatters/linters at all | For PHP/JS/TS/Go/Python/Terraform work, format-on-save and inline linting are as important as LSP hover/completion. This was entirely missing. | Added `conform.nvim` (formatting) + `nvim-lint` (linting), mapped per filetype. |
| Tmux ↔ Neovim navigation not unified | The plan binds `h/j/k/l` inside tmux only. Moving between a tmux pane and a Neovim split needed two different keys. | Added `vim-tmux-navigator` so `Ctrl-h/j/k/l` moves seamlessly across both. |
| No session persistence | If tmux's server dies (reboot, crash), everything is lost. | Added `tpm` + `tmux-resurrect` + `tmux-continuum`. |
| Claude Code + tmux integration was hand-wavy | Step 7 said "run `claude` in a tmux window" but didn't address the two things that actually break: **Shift+Enter** for newlines, and **desktop notifications**, both of which silently fail inside tmux by default. | Added the exact 3 lines Anthropic's docs specify for this. |
| Terminal choice | Alacritty is a perfectly valid, fast, minimal choice (and matches what your videos used) — but as of 2026 it's no longer the default recommendation for macOS: it has no ligatures, hasn't evolved much, and Ghostty now matches its speed while feeling native and needing less bolted-on config. | Recommending **Ghostty** as primary (config included below); your original Alacritty config is still valid if you'd rather stick with what the videos showed — see the note at the end. |

Everything below is the corrected, complete plan.

---

## Step 1: Terminal — Ghostty (recommended)

**Why Ghostty over Alacritty for you specifically:**
- Written in Zig, uses native macOS APIs (Metal/AppKit) — genuinely native window behavior on Apple Silicon, not a generic cross-platform shell.
- Effectively ties Alacritty on raw input latency (~2-3ms either way) but adds ligature support, a real (if minimal) config format, and native tabs/splits as a fallback if tmux is ever unavailable.
- Ships with Shift+Enter support **out of the box** for Claude Code — Alacritty needs a manual keybinding for this (shown below if you go that route).
- Still pairs perfectly with tmux for session/window management — it doesn't try to replace tmux, it just renders faster and looks more native while doing it.

If you'd genuinely rather stick with Alacritty (it's not a wrong choice — it's simply the more minimalist, "does one thing" option and is what both your videos used), skip to the **Alacritty alternative** note at the end; everything else in this plan is identical either way.

```bash
# Install Ghostty
brew install --cask ghostty
```

Config lives at `~/.config/ghostty/config` (plain `key = value` text, not TOML/YAML):

```bash
mkdir -p ~/.config/ghostty
```

`~/.config/ghostty/config`:

```
# Font
font-family = JetBrainsMono Nerd Font
font-size = 14
font-thicken = true

# Window
window-padding-x = 12
window-padding-y = 12
window-padding-balance = true
background-opacity = 0.92
background-blur = 20
unfocused-split-opacity = 0.6

# macOS
macos-option-as-alt = left
shell-integration = detect
window-save-state = always

# Theme (Tokyo Night to match the Neovim colorscheme below)
theme = tokyonight_storm

# Cursor / mouse
cursor-style = block
cursor-style-blink = true
mouse-hide-while-typing = true
copy-on-select = clipboard

# Keep true 256-color terminfo for tmux
term = xterm-256color
```

Reload with `Cmd+Shift+,` after editing — no restart needed. Browse built-in themes with `ghostty +list-themes` if you want to try alternatives.

---

## Step 2: Install Dependencies (Apple Silicon)

```bash
# Core tooling
brew install tmux ripgrep fzf coreutils

# Nerd Font (no tap needed — see corrections table above)
brew install --cask font-jetbrains-mono-nerd-font

# Language runtimes / toolchains for your actual stack
brew install node python go pipx      # JS/TS + Python + Go
brew install php composer             # PHP — was missing entirely from the original plan
brew install terraform                # Terraform CLI (fmt/validate), separate from the LSP
pipx ensurepath

# tmux plugin manager (used in Step 4)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

A note on PHP: `intelephense` (your PHP LSP) works free for basic completion/hover/diagnostics, but **rename and some code actions require a paid license** (one-time purchase, listed on intelephense.com). Free tier is enough to get productive; buy the license later if the LSP warnings about premium features bother you.

---

## Step 3: Zsh — Oh-My-Zsh, with your config in `$ZSH_CUSTOM` (not `.zshrc`)

Updated per your note: since you keep aliases in Oh-My-Zsh's custom directory rather than `.zshrc`, everything below follows that same pattern.

Your `~/.zshrc` should already have the standard OMZ boilerplate:

```bash
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"   # whatever theme you're already on
plugins=(git)
source $ZSH/oh-my-zsh.sh
```

Any `*.zsh` file you drop inside `$ZSH_CUSTOM` (defaults to `~/.oh-my-zsh/custom/`) is auto-sourced by that last line — no manual `source` needed, and unlike `.zshrc` it survives `omz update` untouched.

### `~/.oh-my-zsh/custom/aliases.zsh`

```bash
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
```

### `~/.oh-my-zsh/custom/exports.zsh`

Keeping environment variables out of `.zshrc` too, for the same reason:

```bash
export EDITOR="nvim"
export VISUAL="nvim"
export PATH="/opt/homebrew/bin:$PATH"
```

### tmux auto-attach — two ways to do it

**Option A — a plain custom file** (closest to the original plan, just relocated):

`~/.oh-my-zsh/custom/tmux-autostart.zsh`
```bash
if [ -z "$TMUX" ] && [ -n "$PS1" ]; then
    tmux attach-session -t dev || tmux new-session -s dev
fi
```

**Option B — Oh-My-Zsh's built-in `tmux` plugin** (more idiomatic given you already manage things as OMZ plugins):

Add `tmux` to your existing plugins array in `~/.zshrc`:
```bash
plugins=(git tmux)
```

Then in `~/.oh-my-zsh/custom/exports.zsh` (or a separate `tmux.zsh`):
```bash
export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_AUTOSTART_ONCE=true   # don't relaunch every time you `source` your shell
export ZSH_TMUX_AUTOCONNECT=true      # reattach to an existing session if one is running
```

One thing worth knowing: this plugin also wraps the `tmux` command in its own alias/function to apply these behaviors. That's harmless here, but if you ever layer on something like `oh-my-tmux` for `.tmux.conf.local` support, the two have been reported to interact oddly — not a concern for the plan in this doc, just flagging it for later. Either option gets you the same auto-attach behavior; Option B just keeps everything expressed as a named OMZ plugin, consistent with how you're already organizing things.

`omz reload`, or open a new terminal tab, to apply any of the above.

---

## Step 4: Tmux (`~/.tmux.conf`)

This adds session persistence and fixes Neovim/tmux pane navigation, plus the Claude Code fixes.

```tmux
# Prefix: Ctrl-a instead of Ctrl-b
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# True color
set -g default-terminal "tmux-256color"
set-option -sa terminal-overrides ",xterm-ghostty:RGB"

set -g mouse on
setw -g mode-keys vi
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 50000
set -sg escape-time 0

# Splits that keep your current path
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# --- Claude Code: required inside tmux ---
# Without these, Shift+Enter submits instead of inserting a newline,
# and desktop notifications/progress bars never reach the outer terminal.
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'

# --- Plugins (installed via TPM: prefix + I) ---
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'   # unifies tmux <-> nvim pane movement

# Session persistence
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'

# Initialize TPM — must stay at the very bottom of the file
run '~/.tmux/plugins/tpm/tpm'
```

Run `tmux source-file ~/.tmux.conf`, then inside tmux press `prefix + I` to install the plugins.

`vim-tmux-navigator` means `Ctrl-h/j/k/l` moves between panes **whether the active pane is tmux or a Neovim split** — no more separate keybinding sets. It requires matching keymaps on the Neovim side, included in Step 6.

Two more Claude Code notes worth knowing (not config, just behavior):
- Run `/terminal-setup` inside Ghostty directly (not inside tmux) the first time — Ghostty already supports Shift+Enter natively, so this is mostly a no-op, but it's a harmless one-time check.
- Use regular tmux, not iTerm2/Ghostty's own multiplexing modes at the same time as tmux — mixing them is what breaks scrollback/mouse selection for some users.

---

## Step 5: Neovim — Directory Layout

Same single-location, Lua-first structure as your plan, with a few files split out for clarity:

```text
~/.config/nvim/
├── init.lua
└── lua/
    └── engineer/
        ├── init.lua
        ├── options.lua
        ├── remaps.lua
        └── plugins/
            ├── colors.lua
            ├── treesitter.lua
            ├── lsp.lua
            ├── completion.lua      # new — blink.cmp
            ├── formatting.lua      # new — conform.nvim
            ├── linting.lua         # new — nvim-lint
            ├── telescope.lua
            └── utilities.lua
```

### `init.lua`

```lua
require("engineer")
```

### `lua/engineer/init.lua`

```lua
require("engineer.options")
require("engineer.remaps")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("engineer.plugins", {
    change_detection = { notify = false }
})
```

### `lua/engineer/options.lua`

Unchanged from your original — it was already sound:

```lua
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes" -- prevents text jump when diagnostics/gitsigns appear
```

### `lua/engineer/remaps.lua`

Same core remaps as your plan, with the tmux-navigator handoff added:

```lua
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Quick format trigger (wired to conform.nvim in formatting.lua)
vim.keymap.set({ "n", "v" }, "<leader>f", function()
    require("conform").format({ async = true, lsp_fallback = true })
end)
```

`vim-tmux-navigator` supplies its own `<C-h/j/k/l>` mappings automatically once installed — no extra remap file needed on the Neovim side, just make sure nothing else in your config claims those keys first.

---

## Step 6: LSP — Native `vim.lsp` API (not the deprecated `require('lspconfig').setup{}` pattern)

### `lua/engineer/plugins/lsp.lua`

```lua
return {
    {
        "neovim/nvim-lspconfig", -- now just supplies default per-server configs, no .setup{} calls
    },
    {
        "mason-org/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
        opts = {
            ensure_installed = {
                "intelephense",  -- PHP
                "ts_ls",         -- JS/TS
                "gopls",         -- Go
                "pyright",       -- Python (types/completion)
                "ruff",          -- Python (fast linting + formatting, native LSP mode)
                "terraformls",   -- Terraform
                "bashls",        -- Shell
                "yamlls",        -- YAML
                "jsonls",        -- JSON
                "lua_ls",        -- Lua (for editing this very config)
            },
            -- automatic_enable defaults to true: installed servers get
            -- vim.lsp.enable()'d for you automatically.
        },
    },
}
```

Per-server customization now happens via `vim.lsp.config()`, which merges with nvim-lspconfig's defaults. Put this in the same file (or split into `after/lsp/*.lua` files if you want, but one file is fine at this scale):

```lua
-- Add this at the bottom of lsp.lua, outside the `return {...}` table,
-- or move into a separate `require("engineer.lsp_settings")` called from init.lua.

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
            telemetry = { enable = false },
        },
    },
})

vim.lsp.config("intelephense", {
    root_markers = { "composer.json", ".git" },
    -- Optional, once you have a license: reads ~/intelephense/licence.txt (note British spelling)
    -- init_options = {
    --     licenceKey = (function()
    --         local f = io.open(os.getenv("HOME") .. "/intelephense/licence.txt", "rb")
    --         if not f then return nil end
    --         local key = f:read("*a"):gsub("%s+", "")
    --         f:close()
    --         return key
    --     end)(),
    -- },
})

vim.lsp.config("gopls", {
    settings = {
        gopls = {
            staticcheck = true,
            gofumpt = true,
        },
    },
})
```

### Keymaps on attach

Add this once, e.g. in `lua/engineer/init.lua` after the plugin setup, or its own small file:

```lua
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    end
})
```

(These are effectively identical to your original mappings — the only real change is *how* the servers get configured and started, not how you use them day to day.)

---

## Step 7: Completion — `blink.cmp` (replaces `nvim-cmp`)

### `lua/engineer/plugins/completion.lua`

```lua
return {
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" },
        version = "1.*",
        opts = {
            keymap = { preset = "default" }, -- Ctrl-y accepts, Ctrl-space opens, arrows/Tab navigate
            appearance = { nerd_font_variant = "mono" },
            completion = { documentation = { auto_show = true } },
            sources = { default = { "lsp", "path", "snippets", "buffer" } },
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
    },
}
```

---

## Step 8: Formatting — `conform.nvim`

This was entirely missing from the original plan. Format-on-save, per filetype, using each language's real toolchain formatter (not the LSP's often-partial formatting):

### `lua/engineer/plugins/formatting.lua`

```lua
return {
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                php = { "php_cs_fixer" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                go = { "goimports", "gofumpt" },
                python = { "ruff_format" },
                terraform = { "terraform_fmt" },
                sh = { "shfmt" },
                yaml = { "prettier" },
                json = { "prettier" },
                markdown = { "prettier" },
                lua = { "stylua" },
            },
            format_on_save = { timeout_ms = 500, lsp_fallback = true },
        },
    },
    {
        -- Auto-installs the CLI formatter binaries above via Mason,
        -- so you don't need to `npm install -g prettier` etc. by hand.
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = {
                "php-cs-fixer", "prettier", "goimports", "gofumpt",
                "shfmt", "stylua", "shellcheck", "eslint_d",
            },
        },
    },
}
```

---

## Step 9: Linting — `nvim-lint`

For diagnostics that aren't already covered by the LSP servers above (Python is fully covered by `ruff`'s native LSP mode, so it's intentionally left out here):

### `lua/engineer/plugins/linting.lua`

```lua
return {
    {
        "mfussenegger/nvim-lint",
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                sh = { "shellcheck" },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
                callback = function() lint.try_lint() end,
            })
        end,
    },
}
```

---

## Step 10: Treesitter

Split out from `lsp.lua` for clarity, expanded slightly (added `vim`/`vimdoc` so editing this very config gets highlighting/folds too):

### `lua/engineer/plugins/treesitter.lua`

```lua
return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "php", "javascript", "typescript", "tsx", "go", "python",
                    "markdown", "markdown_inline", "bash", "yaml", "json",
                    "terraform", "hcl", "lua", "vim", "vimdoc", "query", "gitcommit", "diff",
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },
}
```

---

## Step 11: Telescope, Colors, Utilities

Telescope and colors are unchanged from your plan — they were correct. Utilities gets two small, high-value additions: `gitsigns.nvim` (since Git is your VCS) and `which-key.nvim` (since you now have a lot of `<leader>` mappings to remember).

### `lua/engineer/plugins/telescope.lua` — unchanged

```lua
return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
            vim.keymap.set("n", "<C-p>", builtin.git_files, {})
            vim.keymap.set("n", "<leader>ps", function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end)
        end
    }
}
```

### `lua/engineer/plugins/colors.lua` — unchanged

```lua
return {
    {
        "folke/tokyonight.nvim",
        config = function()
            vim.cmd("colorscheme tokyonight-storm")
            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        end
    }
}
```

### `lua/engineer/plugins/utilities.lua` — original three plus two additions

```lua
return {
    {
        "ThePrimeagen/harpoon",
        config = function()
            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")
            vim.keymap.set("n", "<leader>a", mark.add_file)
            vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)
            vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end)
            vim.keymap.set("n", "<C-j>", function() ui.nav_file(2) end)
            vim.keymap.set("n", "<C-k>", function() ui.nav_file(3) end)
            vim.keymap.set("n", "<C-l>", function() ui.nav_file(4) end)
        end
    },
    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    },
    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
        end
    },
    {
        -- new: inline git diff markers in the gutter + hunk navigation
        "lewis6991/gitsigns.nvim",
        opts = {},
    },
    {
        -- new: discoverability for all the <leader> mappings above
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
    },
}
```

> Note: Harpoon's `<C-h/j/k/l>` mappings above will **collide** with `vim-tmux-navigator`'s pane-navigation keys of the same name. Pick one convention — either remap Harpoon's file nav to something like `<leader>1/2/3/4`, or accept that Harpoon's keys only work when you're not trying to jump tmux panes from that spot. I'd remap Harpoon, since seamless tmux/nvim navigation is more valuable day-to-day:
> ```lua
> vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end)
> vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end)
> vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end)
> vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end)
> ```

---

## Step 12: Claude Code — Multi-Window Workflow

Same core idea as your original plan (Claude Code gets its own tmux window rather than an editor split), now with the actual integration fixed by Step 4's tmux config:

1. `dev:1` — Neovim, full screen, editing.
2. `prefix + c` — new tmux window `dev:2`, run `claude` there.
3. `prefix + 1` / `prefix + 2` to flip between them. With `allow-passthrough on` and the extended-keys lines from Step 4, Shift+Enter and desktop notifications now work correctly from inside tmux.
4. When Claude edits a file Neovim has open, Neovim's default `autoread`-on-focus behavior picks it up when you switch back — no manual reload needed for most cases (add `vim.o.autoread = true` and an `au FocusGained,BufEnter * checktime` autocommand in `options.lua` if you notice stale buffers).

---

## Install Order

1. Ghostty + Nerd Font + tmux + language runtimes + Composer + Terraform (Step 2).
2. Zsh config, `source ~/.zshrc` (Step 3).
3. Tmux config + `git clone` TPM, then `prefix + I` inside tmux (Step 4).
4. Neovim config files (Steps 5–11), then open `nvim` — `lazy.nvim` bootstraps and installs plugins automatically on first launch.
5. Open a PHP or Go file and run `:checkhealth vim.lsp` to confirm servers attach correctly.
6. Confirm Claude Code's Shift+Enter and notifications work inside a tmux pane.

---

## If you'd rather keep Alacritty instead of Ghostty

Everything above is terminal-agnostic except Step 1. Alacritty is genuinely fine — faster startup, dead simple TOML config, and it's what your two videos used. The only two things to change:
- Drop the deprecated tap line: use `brew install --cask font-jetbrains-mono-nerd-font` directly (no `brew tap homebrew/cask-fonts` first).
- Add this to `alacritty.toml` so Shift+Enter reaches Claude Code correctly:
```toml
[[keyboard.bindings]]
key = "Return"
mods = "Shift"
chars = "\u001b[13;2u"
```
Your original `alacritty.toml` content (window padding, font, Tokyo Night palette) is otherwise accurate and can be used as-is.
