# Neovim IDE Setup

Implementation of `neovim-ide-setup-plan.md` for PHP, JS/TS, Go, Python,
Markdown/Shell/YAML/JSON/Terraform, on Apple Silicon.

## Contents

```
neovim-ide-setup/
├── install.sh              # bootstraps everything below
├── ghostty/config           -> ~/.config/ghostty/config
├── alacritty/alacritty.toml -> ~/.config/alacritty/alacritty.toml (alternative)
├── tmux/tmux.conf           -> ~/.tmux.conf
├── tmux/policyr-session.sh   # `policyr` alias — recreates + attaches the session
├── zsh/
│   ├── aliases.zsh          -> $ZSH_CUSTOM/aliases.zsh  (incl. dev/policyr tmux aliases)
│   └── exports.zsh          -> $ZSH_CUSTOM/exports.zsh
└── nvim/                    -> ~/.config/nvim/
    ├── init.lua
    └── lua/engineer/
        ├── init.lua
        ├── options.lua
        ├── remaps.lua
        ├── lsp_keymaps.lua
        ├── lsp_settings.lua
        └── plugins/
            ├── colors.lua
            ├── treesitter.lua
            ├── lsp.lua
            ├── completion.lua
            ├── formatting.lua
            ├── linting.lua
            ├── telescope.lua
            └── utilities.lua
```

## Install

Run on the target Mac (not in this sandbox — these commands touch `brew`,
`~/.config`, and `~/.oh-my-zsh`, none of which exist here):

```bash
cd neovim-ide-setup
chmod +x install.sh
./install.sh              # Ghostty (recommended)
# or
./install.sh --alacritty  # keep Alacritty instead
```

The script installs Homebrew packages (neovim, tmux, ripgrep, fzf, coreutils,
lazygit, the Nerd Font, node/python/go/pipx, php/composer, terraform), clones
`tpm`, and symlinks every config file into place — backing up anything
already there as `<file>.bak-<timestamp>` rather than clobbering it. Because
it's a symlink back into this cloned repo, editing a file here takes effect
immediately, in every clone/install, with no re-run or re-copy step.

### After install.sh finishes

1. Open a new terminal tab (or `omz reload`).
2. Inside tmux, press `prefix + I` (`Ctrl-a` then `I`) to install tmux
   plugins via TPM (tmux-sensible, resurrect, continuum, yank,
   vim-tmux-navigator).
3. Run `nvim` — `lazy.nvim` bootstraps itself and installs all plugins on
   first launch.
4. Open a PHP or Go file and run `:checkhealth vim.lsp` to confirm the LSP
   servers (intelephense, ts_ls, gopls, pyright, ruff, terraformls, bashls,
   yamlls, jsonls, lua_ls) attach.
5. In a tmux pane, run `claude` and confirm Shift+Enter inserts a newline
   (not submit) and that desktop notifications arrive.

## Notable implementation choices (where the source plan left a decision open)

- **Harpoon vs. tmux-navigator key collision**: the plan flagged that
  Harpoon's `<C-h/j/k/l>` file-nav keys collide with vim-tmux-navigator's
  pane-nav keys of the same name, and recommended remapping Harpoon. This is
  implemented as `<leader>1/2/3/4` in `utilities.lua`.
- **vim-tmux-navigator on the Neovim side**: the plan lists it as a tmux
  plugin (installed via TPM in `tmux.conf`) but the Ctrl-h/j/k/l Neovim-side
  mappings only exist once the plugin is also loaded by `lazy.nvim`, so it's
  added to `utilities.lua` (`lazy = false`) to actually make the feature
  work end-to-end.
- **LSP per-server settings**: split into their own `lsp_settings.lua`
  (loaded from `engineer/init.lua`) and buffer-local keymaps into
  `lsp_keymaps.lua`, per the plan's suggested "or move into a separate file"
  option, rather than appending them inline in `plugins/lsp.lua`.
- **Autoread for Claude Code edits**: `vim.o.autoread = true` plus a
  `FocusGained,BufEnter -> checktime` autocommand added to `options.lua`,
  per Step 12's note about picking up file changes made by Claude Code in
  the adjacent tmux window.
- **Manual tmux attach**: the terminal no longer auto-attaches to tmux on
  launch. Attach with the `policyr` alias in `zsh/aliases.zsh`, which attaches
  to the saved PolicyR session — recreating its layout (nvim top-left, a shell
  bottom-left, Claude Code in the narrow right column) via
  `tmux/policyr-session.sh` if it isn't already running.

  Earlier versions prepended an auto-attach block to the top of `~/.zshrc`;
  re-running `install.sh` now strips that block (after backing up `~/.zshrc`).
- **intelephense license**: left commented out in `lsp_settings.lua` — free
  tier works for hover/completion/diagnostics; uncomment and point at
  `~/intelephense/licence.txt` if you buy the paid license later for
  rename/code-actions.

## Ghostty vs. Alacritty

Both configs are included. Ghostty is the plan's primary recommendation
(native macOS rendering, ligatures, Shift+Enter for Claude Code out of the
box). Alacritty remains fully supported — `install.sh --alacritty` installs
it instead and applies the two macOS tweaks Ghostty handles natively: the
Shift+Enter keybinding for Claude Code, and `option_as_alt = "OnlyLeft"` so
Alt-based keys (tmux `Alt+1`–`5` pane-nav, Neovim `Alt-,`/`Alt-.` buffer
cycle) reach the app instead of typing accented characters.
