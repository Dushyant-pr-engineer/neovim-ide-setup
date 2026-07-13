# Cleaning Up User-Specific Dependencies

The `neovim-ide-setup` repo includes configurations tailored to the original author's workflow (PHP development on the Policyr project). If you're reusing this setup, you may want to remove or customize these user-specific parts.

## What's User-Specific?

### Tmux
- **`tmux/policyr-session.sh`** — Creates a tmux session specifically for the Policyr project with a fixed layout (nvim top-left, shell bottom-left, Claude Code right). Safe to delete if you don't use this session structure.
- **`zsh/aliases.zsh`** — Contains the `policyr` alias that attaches to the saved Policyr session. You can edit or delete this alias.

### Zsh Aliases
- **`zsh/devAlias.zsh`** — Contains aliases (`jstest`, `phinx`, `phpunit`, etc.) tied to the Policyr project. Safe to delete or customize with your own project aliases.
  - `jstest` — runs tests in the Portal project (Policyr-specific)
  - `phpunit`, `pfunit`, `phinx` — Docker aliases for Policyr development
  - `policyr_error_log`, `xdebug_log` — logs specific to Policyr's Docker setup

- **`zsh/generalAlias.zsh`** — Contains:
  - `ToWinBook` / `toWinBook` — hardcoded path to user's OneDrive; delete or customize

### Environment Variables
- **`POLICYR_PATH`** — Used throughout the setup (in aliases, Docker scripts, etc.). If you don't have this project, the setup will fall back to `$HOME/src/ops/policyr` automatically. You can safely ignore it.

### Documentation
- **`Docs/project-workflow.md`** — Uses Policyr as an example workflow. Concepts apply to any project, but examples are specific.
- **`Docs/debugging-setup.md`** — Uses Policyr's Docker + PHP/JS setup as examples. Concepts apply to other stacks.

## What's Generic (Keep This)

- ✅ **Ghostty/Alacritty config** — Terminal setup, not project-specific
- ✅ **Tmux core config** (`tmux.conf`) — Session management, keybindings, plugins
- ✅ **Zsh + Oh-My-Zsh setup** — Shell framework, theme (Powerlevel10k), plugins
- ✅ **Neovim config** — LSP, DAP, formatters, linters for multiple languages
- ✅ **General aliases** (`zsh/aliases.zsh`, `zsh/exports.zsh`) — nvim, git, system aliases
- ✅ **install.sh** — Bootstraps everything above

## Quick Cleanup

Run the cleanup script to remove user-specific files:

```bash
cd neovim-ide-setup
bash Cleanup/remove-user-specific.sh
```

This will:
- Remove `tmux/policyr-session.sh`
- Remove `zsh/devAlias.zsh`
- Remove hardcoded `ToWinBook` aliases from `zsh/generalAlias.zsh`
- Remove project-workflow and debugging guide (you can restore these from git if needed)

After cleanup, run `install.sh` to re-symlink the remaining files.

## Manual Cleanup Steps

If you prefer to do it selectively:

1. **Delete Policyr-specific alias file:**
   ```bash
   rm zsh/devAlias.zsh
   ```
   Then remove the `policyr` alias from `zsh/aliases.zsh` if you added it.

2. **Remove ToWinBook aliases:**
   Edit `zsh/generalAlias.zsh` and delete these lines:
   ```bash
   alias ToWinBook="cd /Users/dushyant.patel/Library/CloudStorage/..."
   alias toWinBook="cd /Users/dushyant.patel/Library/CloudStorage/..."
   ```

3. **Delete Policyr session script:**
   ```bash
   rm tmux/policyr-session.sh
   ```

4. **Update documentation for your project:**
   - Rename/edit `Docs/project-workflow.md` to match your workflow
   - Update `Docs/debugging-setup.md` with your stack (replace Policyr PHP/JS examples with your own)

5. **Update `.env.example`:**
   Remove Policyr-specific secrets and add your own:
   ```bash
   # Remove these if not needed:
   # PR_USERNAME=
   # PR_PASSWORD=
   
   # Add your project's secrets:
   # MY_PROJECT_API_KEY=
   ```

6. **Update `~/.zshrc.local`:**
   Remove any POLICYR_PATH override and add your own project paths:
   ```bash
   # Instead of:
   # export POLICYR_PATH="$HOME/src/ops/policyr"
   
   # Use:
   # export MY_PROJECT_PATH="$HOME/src/my-project"
   ```

## After Cleanup

The setup becomes a generic, portable **PHP/JS/Go/Python IDE** with:
- Persistent tmux sessions (yours to configure)
- Modern Neovim with LSP, debugging, formatting, linting
- Keyboard-driven workflow (Tmux + Vim + Claude Code)
- Multi-language support

You can now customize it for your own project stack.
