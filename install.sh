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

set -euo pipefail

TERMINAL="ghostty"
if [[ "${1:-}" == "--alacritty" ]]; then
    TERMINAL="alacritty"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"

backup_and_copy() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" || -L "$dest" ]]; then
        echo "Backing up existing $dest -> ${dest}.bak-${STAMP}"
        mv "$dest" "${dest}.bak-${STAMP}"
    fi
    cp -R "$src" "$dest"
    echo "Installed $dest"
}

echo "== Step 1: Terminal =="
if [[ "$TERMINAL" == "ghostty" ]]; then
    brew install --cask ghostty
    backup_and_copy "$SCRIPT_DIR/ghostty/config" "$HOME/.config/ghostty/config"
else
    brew install --cask alacritty
    backup_and_copy "$SCRIPT_DIR/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
fi

echo "== Step 2: Dependencies (Apple Silicon) =="
brew install tmux ripgrep fzf coreutils
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
    backup_and_copy "$SCRIPT_DIR/zsh/aliases.zsh" "$ZSH_CUSTOM_DIR/aliases.zsh"
    backup_and_copy "$SCRIPT_DIR/zsh/exports.zsh" "$ZSH_CUSTOM_DIR/exports.zsh"
    backup_and_copy "$SCRIPT_DIR/zsh/tmux-autostart.zsh" "$ZSH_CUSTOM_DIR/tmux-autostart.zsh"
fi

echo "== Step 4: Tmux =="
backup_and_copy "$SCRIPT_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

echo "== Step 5: Neovim =="
backup_and_copy "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"

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
