#!/usr/bin/env bash
# Neovim IDE setup — bootstraps everything from neovim-ide-setup-plan.md
# (PHP, JS/TS, Go, Python, Markdown/Shell/YAML/JSON/Terraform, Apple Silicon).
#
# Usage:
#   chmod +x install.sh
#   ./install.sh              # Ghostty (recommended)
#   ./install.sh --alacritty  # keep Alacritty instead of Ghostty
#
# Safe to re-run: existing config files are backed up with a .bak-<timestamp>
# suffix rather than silently overwritten.
#
# Config is deployed via symlinks back into this repo (not copies), so
# editing a file here takes effect immediately — no re-run needed to pick up
# changes. Also means: don't move or delete this cloned repo directory.

set -euo pipefail

TERMINAL="ghostty"
if [[ "${1:-}" == "--alacritty" ]]; then
    TERMINAL="alacritty"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"

backup_and_symlink() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [[ -L "$dest" ]]; then
        if [[ "$(readlink "$dest")" == "$src" ]]; then
            echo "$dest already symlinked to $src, skipping"
            return
        fi
        echo "Removing existing symlink $dest -> $(readlink "$dest")"
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        echo "Backing up existing $dest -> ${dest}.bak-${STAMP}"
        mv "$dest" "${dest}.bak-${STAMP}"
    fi
    ln -s "$src" "$dest"
    echo "Symlinked $dest -> $src"
}

echo "== Step 1: Terminal =="
if [[ "$TERMINAL" == "ghostty" ]]; then
    brew install --cask ghostty
    backup_and_symlink "$SCRIPT_DIR/ghostty/config" "$HOME/.config/ghostty/config"
else
    brew install --cask alacritty
    backup_and_symlink "$SCRIPT_DIR/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
fi

echo "== Step 2: Dependencies (Apple Silicon) =="
brew install neovim tmux ripgrep fzf coreutils lazygit
brew install --cask font-jetbrains-mono-nerd-font
brew install node python go pipx
brew install php composer
brew install terraform
pipx ensurepath

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    echo "tpm already installed, skipping clone"
fi

echo "== Step 3: Zsh (Oh-My-Zsh custom dir) =="
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Oh-My-Zsh not found at ~/.oh-my-zsh — install it first (https://ohmyz.sh), then re-run this script."
else
    backup_and_symlink "$SCRIPT_DIR/zsh/aliases.zsh" "$ZSH_CUSTOM_DIR/aliases.zsh"
    backup_and_symlink "$SCRIPT_DIR/zsh/exports.zsh" "$ZSH_CUSTOM_DIR/exports.zsh"

    # tmux-autostart.zsh is NOT a $ZSH_CUSTOM file: oh-my-zsh.sh (and thus
    # $ZSH_CUSTOM) is sourced after Powerlevel10k's instant-prompt block has
    # already started, and tmux needs to take over the tty before that block
    # runs (see the comment inside zsh/tmux-autostart.zsh). So it gets
    # prepended directly to the top of ~/.zshrc instead, guarded by a marker
    # so re-running this script doesn't duplicate it.
    TMUX_MARKER="# >>> neovim-ide-setup tmux auto-attach >>>"
    if [[ -f "$HOME/.zshrc" ]] && grep -qF "$TMUX_MARKER" "$HOME/.zshrc"; then
        echo "tmux auto-attach already present in ~/.zshrc, skipping"
    else
        echo "Backing up ~/.zshrc -> ~/.zshrc.bak-${STAMP} (if it exists)"
        [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$HOME/.zshrc.bak-${STAMP}"
        {
            cat "$SCRIPT_DIR/zsh/tmux-autostart.zsh"
            echo
            [[ -f "$HOME/.zshrc" ]] && cat "$HOME/.zshrc"
        } >"$HOME/.zshrc.new"
        mv "$HOME/.zshrc.new" "$HOME/.zshrc"
        echo "Prepended tmux auto-attach to the top of ~/.zshrc"
    fi
fi

echo "== Step 4: Tmux =="
backup_and_symlink "$SCRIPT_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

echo "== Step 5: Neovim =="
backup_and_symlink "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"

cat <<'EOF'

Install complete. Remaining manual steps:

1. Open a new terminal tab (or `omz reload`) to pick up the Zsh changes.
2. Start tmux (`tmux new -s dev` or just open a new terminal — auto-attach
   is wired up) and press `prefix + I` (Ctrl-a then I) to install tmux
   plugins via TPM.
3. Launch `nvim` — lazy.nvim bootstraps itself and installs all plugins on
   first run.
4. Open a PHP or Go file and run `:checkhealth vim.lsp` to confirm LSP
   servers attach correctly.
5. Confirm Shift+Enter and desktop notifications work for Claude Code
   inside a tmux pane.

See README.md in this folder for details and the Alacritty-vs-Ghostty note.
EOF
