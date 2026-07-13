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

echo "== Step 3: Zsh (Oh-My-Zsh + Powerlevel10k) =="
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# 3a. Install Oh-My-Zsh if missing (unattended, leaving login shell + ~/.zshrc
# alone — we symlink our own ~/.zshrc just below).
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh-My-Zsh (unattended)..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh-My-Zsh already installed, skipping"
fi

# 3b. Install Powerlevel10k theme if missing.
P10K_DIR="$ZSH_CUSTOM_DIR/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
    echo "Cloning Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "Powerlevel10k already installed, skipping clone"
fi

# 3c. Install third-party plugins listed in zsh/plugins.txt ("name url" per line).
if [[ -f "$SCRIPT_DIR/zsh/plugins.txt" ]]; then
    while read -r name url _; do
        [[ -z "$name" || "$name" == \#* ]] && continue
        dest="$ZSH_CUSTOM_DIR/plugins/$name"
        if [[ ! -d "$dest" ]]; then
            echo "Cloning plugin $name..."
            git clone --depth=1 "$url" "$dest"
        else
            echo "Plugin $name already installed, skipping"
        fi
    done < "$SCRIPT_DIR/zsh/plugins.txt"
fi

# 3d. Symlink our *.zsh snippets into $ZSH_CUSTOM (oh-my-zsh auto-sources them).
# Skip p10k.zsh — it's linked to ~/.p10k.zsh below, not sourced from custom.
for f in "$SCRIPT_DIR"/zsh/*.zsh; do
    base="$(basename "$f")"
    [[ "$base" == "p10k.zsh" ]] && continue
    backup_and_symlink "$f" "$ZSH_CUSTOM_DIR/$base"
done

# 3e. Symlink the managed .zshrc and Powerlevel10k config into $HOME. The .zshrc
# link backs up any existing real ~/.zshrc to ~/.zshrc.bak-<STAMP>, preserving
# prior secrets/machine config for migration into ~/.zshrc.local.
backup_and_symlink "$SCRIPT_DIR/zsh/zshrc" "$HOME/.zshrc"
backup_and_symlink "$SCRIPT_DIR/zsh/p10k.zsh" "$HOME/.p10k.zsh"

# 3f. Symlink project .env to ~/.env so zshrc can source project secrets in every shell.
# This keeps secrets in one place (the repo's .env) while making them available to
# the interactive shell. Never commit .env — it's already .gitignored.
backup_and_symlink "$SCRIPT_DIR/.env" "$HOME/.env"

# 3g. Seed ~/.zshrc.local (machine-specific config) from the template if it
# doesn't exist yet — never overwrite an existing one. This file stays in home
# and is NEVER committed; it's for per-machine config like PATH, NVM, docker
# completions, php flags, and any secrets you don't want to share (test creds, etc).
if [[ ! -f "$HOME/.zshrc.local" ]]; then
    cp "$SCRIPT_DIR/zsh/zshrc.local.example" "$HOME/.zshrc.local"
    echo "Created ~/.zshrc.local from template — add machine-specific config there."
    echo "  (Any previous ~/.zshrc was backed up to ~/.zshrc.bak-*; copy secrets from it.)"
else
    echo "~/.zshrc.local already exists, leaving it untouched"
fi

echo "== Step 4: Tmux =="
backup_and_symlink "$SCRIPT_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

echo "== Step 5: Neovim =="
backup_and_symlink "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"

echo "== Step 5b: PHP debug adapter (vscode-php-debug) =="
PHP_DEBUG_DIR="$HOME/.local/share/vscode-php-debug"
if [[ ! -d "$PHP_DEBUG_DIR" ]]; then
    git clone https://github.com/xdebug/vscode-php-debug "$PHP_DEBUG_DIR"
    (cd "$PHP_DEBUG_DIR" && npm install && npm run build)
else
    echo "vscode-php-debug already installed, skipping"
fi

echo "== Step 6: Secrets (.env) =="
if [[ -f "$SCRIPT_DIR/.env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/.env"
    set +a

    if [[ -n "${WAKATIME_API_KEY:-}" ]]; then
        if [[ -f "$HOME/.wakatime.cfg" ]] && ! grep -q "^api_key = ${WAKATIME_API_KEY}$" "$HOME/.wakatime.cfg"; then
            echo "Backing up existing ~/.wakatime.cfg -> ~/.wakatime.cfg.bak-${STAMP}"
            cp "$HOME/.wakatime.cfg" "$HOME/.wakatime.cfg.bak-${STAMP}"
        fi
        cat >"$HOME/.wakatime.cfg" <<EOF
[settings]
api_key = ${WAKATIME_API_KEY}
EOF
        echo "Wrote WAKATIME_API_KEY to ~/.wakatime.cfg"
    else
        echo "WAKATIME_API_KEY not set in .env, skipping ~/.wakatime.cfg"
    fi
else
    echo "No .env file found at $SCRIPT_DIR/.env, skipping secrets setup."
    echo "  Copy .env.example to .env and fill in your keys (e.g. WAKATIME_API_KEY) to enable this step."
fi

cat <<'EOF'

Install complete. Remaining manual steps:

0. Fill in ~/.zshrc.local with your secrets + machine-specific config
   (API keys, PATH, php flags, NVM, ...). On an upgrade, copy them from the
   ~/.zshrc.bak-* backup this run created. This file is never committed.
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
