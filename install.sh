#!/usr/bin/env bash
# Neovim IDE setup — bootstraps everything from neovim-ide-setup-plan.md
# (PHP, JS/TS, Go, Python, Markdown/Shell/YAML/JSON/Terraform, Apple Silicon).
#
# Usage:
#   chmod +x install.sh
#   ./install.sh              # prompts to choose a terminal (Ghostty/Alacritty)
#   ./install.sh --ghostty    # skip the prompt, use Ghostty (recommended)
#   ./install.sh --alacritty  # skip the prompt, use Alacritty
#
# Safe to re-run: existing config files are backed up with a .bak-<timestamp>
# suffix rather than silently overwritten.
#
# Config is deployed via symlinks back into this repo (not copies), so
# editing a file here takes effect immediately — no re-run needed to pick up
# changes. Also means: don't move or delete this cloned repo directory.

set -euo pipefail

TERMINAL=""
case "${1:-}" in
    --ghostty)   TERMINAL="ghostty" ;;
    --alacritty) TERMINAL="alacritty" ;;
esac

# No flag given — prompt interactively for the terminal app.
if [[ -z "$TERMINAL" ]]; then
    echo "Which terminal app do you want to install and configure?"
    echo "  1) Ghostty (recommended)"
    echo "  2) Alacritty"
    while [[ -z "$TERMINAL" ]]; do
        read -rp "Enter choice [1]: " choice
        case "${choice:-1}" in
            1) TERMINAL="ghostty" ;;
            2) TERMINAL="alacritty" ;;
            *) echo "Please enter 1 or 2." ;;
        esac
    done
fi
echo "Selected terminal: $TERMINAL"

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

    # tmux is now attached manually via the `dev` / `policyr` aliases in
    # zsh/aliases.zsh (see below) — the terminal no longer auto-attaches on
    # launch. Strip any auto-attach block left in ~/.zshrc by earlier runs.
    TMUX_OPEN="# >>> neovim-ide-setup tmux auto-attach >>>"
    TMUX_CLOSE="# <<< neovim-ide-setup tmux auto-attach <<<"
    if [[ -f "$HOME/.zshrc" ]] && grep -qF "$TMUX_OPEN" "$HOME/.zshrc"; then
        echo "Backing up ~/.zshrc -> ~/.zshrc.bak-${STAMP}"
        cp "$HOME/.zshrc" "$HOME/.zshrc.bak-${STAMP}"
        awk -v o="$TMUX_OPEN" -v c="$TMUX_CLOSE" '
            $0==o {skip=1}
            !skip {print}
            $0==c {skip=0}
        ' "$HOME/.zshrc.bak-${STAMP}" >"$HOME/.zshrc"
        echo "Removed tmux auto-attach block from ~/.zshrc (now manual)"
    fi
fi

echo "== Step 4: Tmux =="
backup_and_symlink "$SCRIPT_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

echo "== Step 5: Neovim =="
backup_and_symlink "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"

cat <<'EOF'

Install complete. Remaining manual steps:

1. Open a new terminal tab (or `omz reload`) to pick up the Zsh changes.
2. Attach to tmux manually with the `policyr` alias (recreates the saved
   PolicyR layout), then press `prefix + I` (Ctrl-a then I) to install tmux
   plugins via TPM.
3. Launch `nvim` — lazy.nvim bootstraps itself and installs all plugins on
   first run.
4. Open a PHP or Go file and run `:checkhealth vim.lsp` to confirm LSP
   servers attach correctly.
5. Confirm Shift+Enter and desktop notifications work for Claude Code
   inside a tmux pane.

See README.md in this folder for details and the Alacritty-vs-Ghostty note.
EOF
