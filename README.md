# Neovim IDE Setup

Complete IDE setup for PHP, JS/TS, Go, Python, Markdown/Shell/YAML/JSON/Terraform,
on Apple Silicon.

## Contents

```
neovim-ide-setup/
├── .env                    # Shared secrets (WakaTime, Context7, test creds); git-ignored
├── .env.example            # Template for .env — copy to .env and fill in real values
├── install.sh              # bootstraps everything below
├── ghostty/config           -> ~/.config/ghostty/config
├── alacritty/alacritty.toml -> ~/.config/alacritty/alacritty.toml (alternative)
├── tmux/tmux.conf           -> ~/.tmux.conf
├── tmux/policyr-session.sh   # `policyr` alias — recreates + attaches the session
├── lazygit/config.yml       -> ~/Library/Application Support/lazygit/config.yml
├── zsh/                     # Oh-My-Zsh + Powerlevel10k, symlinked into place
│   ├── zshrc                -> ~/.zshrc               (theme + plugins array; sources ~/.env)
│   ├── p10k.zsh             -> ~/.p10k.zsh            (Powerlevel10k config)
│   ├── plugins.txt          # third-party plugins cloned into $ZSH_CUSTOM/plugins
│   ├── zshrc.local.example  # copied to ~/.zshrc.local (machine-specific config only; git-ignored)
│   ├── aliases.zsh          -> $ZSH_CUSTOM/aliases.zsh  (nvim + general aliases)
│   ├── exports.zsh          -> $ZSH_CUSTOM/exports.zsh
│   └── policyrAlias.zsh     -> $ZSH_CUSTOM/policyrAlias.zsh  (policyr tmux alias, dev aliases, pr-* API testing functions)
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

For Zsh it's a full bootstrap: it installs Oh-My-Zsh (unattended) and clones
Powerlevel10k + the plugins in `zsh/plugins.txt` if they're missing, then
symlinks `zsh/zshrc → ~/.zshrc`, `zsh/p10k.zsh → ~/.p10k.zsh`, and every
`zsh/*.zsh` snippet into `$ZSH_CUSTOM`. It leaves your login shell alone
(`chsh -s $(which zsh)` yourself on a brand-new machine if zsh isn't already
the default).

### Customizing for Your Project

This setup includes author-specific configurations (Policyr tmux session, project
aliases, machine paths). If you're reusing this for your own project, see
[**Cleanup/README.md**](Cleanup/README.md) for an automated script to strip away
user-specific dependencies and customize for your stack.

### After install.sh finishes

1. **Copy `.env.example` to `.env` and fill in your real secrets** (API keys,
   test credentials). This file is `.gitignore`d and never committed. The
   secrets are automatically sourced in every shell from `~/.env` (a symlink
   created by `install.sh`). See "Secrets & machine-specific config" below.
1. **Fill in `~/.zshrc.local` with machine-specific config** (`PATH`, php flags,
   NVM, docker completions, etc.). This file is never committed. On an upgrade,
   copy machine-specific settings from the `~/.zshrc.bak-<timestamp>` backup
   this run created.
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

## Zsh (Oh-My-Zsh + Powerlevel10k)

`~/.zshrc` and `~/.p10k.zsh` are symlinks to `zsh/zshrc` and `zsh/p10k.zsh` in
this repo, so shell config is versioned and shared across machines — edit the
repo copy and open a new tab (or `omz reload`). Everything the shell loads comes
from four places:

- **`zsh/zshrc`** — the theme selection, the `plugins=(...)` array, and sourcing of `~/.env`.
- **`~/.env`** — symlinked to `.env` in the repo. Contains shared secrets
  (API keys, test credentials). Copy `.env.example` → `.env` and fill in real values.
- **`zsh/*.zsh` snippets** — symlinked into `$ZSH_CUSTOM` and auto-sourced by
  Oh-My-Zsh (`aliases.zsh`, `exports.zsh`, `policyrAlias.zsh`). Good for
  aliases/functions/exports.
- **`~/.zshrc.local`** — machine-specific config only (PATH, php build flags, NVM,
  Docker completions, etc.), sourced last. Stays in home, never committed.

### Secrets & machine-specific config

**Shared secrets** (API keys, test credentials used across machines) live in
`.env` at the project root, which is `.gitignore`d and never committed. `install.sh`
symlinks `.env` to `~/.env`, so the secrets are automatically available in every
shell. Examples: `WAKATIME_API_KEY`, `CONTEXT7_API_KEY`.
See `.env.example` for the template.

**Machine-specific config** (things that vary per machine) lives in `~/.zshrc.local`,
which is never committed. `install.sh` seeds it from `zsh/zshrc.local.example` on
a fresh install. Examples: `PATH` tweaks, NVM setup, PHP build flags, Docker
completions.

This separation keeps shared secrets in version control (via `.env.example` as a
template) while keeping machine-specific settings local — no one accidentally
commits their custom `PATH` or NVM setup.

### Add an alias / function

Edit an existing `zsh/*.zsh` snippet (or add a new `zsh/<name>.zsh` and re-run
`install.sh` to symlink it into `$ZSH_CUSTOM`). It's live in the next new shell.

### Enable a plugin

1. If it's a third-party plugin, add a `name url` line to `zsh/plugins.txt`
   (re-running `install.sh` clones it into `$ZSH_CUSTOM/plugins/<name>`).
2. Add the plugin name to the `plugins=(...)` array in `zsh/zshrc`. Keep
   `fast-syntax-highlighting` last — it wraps ZLE and must load after the rest.

### Fonts

Powerlevel10k runs in `nerdfont-v3` mode, rendered by the terminals' configured
**JetBrainsMono Nerd Font** (installed via the `font-jetbrains-mono-nerd-font`
cask in Step 2). MesloLGS NF — p10k's own default recommendation — also works if
you prefer it; no config change is required either way.

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

  Earlier versions prepended an auto-attach block to the top of `~/.zshrc`.
  Now that `~/.zshrc` is a repo-managed symlink (`zsh/zshrc`), that block is
  simply absent — the first `install.sh` run backs up your previous real
  `~/.zshrc` to `~/.zshrc.bak-<timestamp>`.
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

## Documentation

- **`Docs/project-workflow.md`** — Day-to-day usage guide: how to work with
  Nvim + Tmux + Claude Code together. Walkthrough of actual workflows
  (navigation, editing, debugging, committing).
- **`Docs/debugging-setup.md`** — Debugging guide for PHP (XDebug + nvim-dap)
  and JavaScript/TypeScript (Chrome DevTools). Includes troubleshooting and
  per-request trigger setup.
- **`vim-tmux-cheatsheet.md`** — Complete key reference: every keybinding in
  Nvim, Tmux, and shell.
- **`Cleanup/README.md`** — If reusing this setup for your own project, this
  explains what's user-specific (Policyr tmux session, project aliases, etc.)
  and what's generic IDE setup. Includes an automated cleanup script to strip
  away author-specific customizations.
