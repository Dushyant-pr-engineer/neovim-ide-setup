#!/bin/bash

# Cleanup script to remove user-specific configurations from neovim-ide-setup
# Keeps the generic IDE setup, removes Policyr/author-specific customizations

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🧹 Cleaning up user-specific configurations..."
echo "   Repository: $REPO_DIR"
echo ""

# Backup important files before modification
TIMESTAMP=$(date +%s)
BACKUP_DIR="$REPO_DIR/.cleanup-backup-$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

# 1. Remove Policyr tmux session script
if [[ -f "$REPO_DIR/tmux/policyr-session.sh" ]]; then
  echo "   ✓ Backing up tmux/policyr-session.sh"
  cp "$REPO_DIR/tmux/policyr-session.sh" "$BACKUP_DIR/"
  rm "$REPO_DIR/tmux/policyr-session.sh"
  echo "   ✓ Removed tmux/policyr-session.sh"
fi

# 2. Remove all Policyr-specific aliases (policyr tmux alias and dev aliases
# like jstest/phinx/phpunit — all consolidated into zsh/policyrAlias.zsh)
if [[ -f "$REPO_DIR/zsh/policyrAlias.zsh" ]]; then
  echo "   ✓ Backing up zsh/policyrAlias.zsh"
  cp "$REPO_DIR/zsh/policyrAlias.zsh" "$BACKUP_DIR/"
  rm "$REPO_DIR/zsh/policyrAlias.zsh"
  echo "   ✓ Removed zsh/policyrAlias.zsh"
fi

# 3. Remove hardcoded ToWinBook aliases from aliases.zsh
if [[ -f "$REPO_DIR/zsh/aliases.zsh" ]] && grep -q "^alias ToWinBook=\|^alias toWinBook=" "$REPO_DIR/zsh/aliases.zsh"; then
  echo "   ✓ Cleaning up zsh/aliases.zsh"

  # Backup before modification
  cp "$REPO_DIR/zsh/aliases.zsh" "$BACKUP_DIR/"

  # Remove ToWinBook lines (both cases) and the preceding comment
  sed -i.bak '/^# Open Win book in terminal$/d; /^alias ToWinBook=/d; /^alias toWinBook=/d' "$REPO_DIR/zsh/aliases.zsh"
  rm "$REPO_DIR/zsh/aliases.zsh.bak"

  echo "   ✓ Removed hardcoded ToWinBook aliases"
fi

# 4. Optional: Remove project-specific docs
read -p "   Remove project-specific documentation? (project-workflow.md, debugging-setup.md) [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [[ -f "$REPO_DIR/Docs/project-workflow.md" ]]; then
    echo "   ✓ Backing up Docs/project-workflow.md"
    cp "$REPO_DIR/Docs/project-workflow.md" "$BACKUP_DIR/"
    rm "$REPO_DIR/Docs/project-workflow.md"
    echo "   ✓ Removed Docs/project-workflow.md"
  fi

  if [[ -f "$REPO_DIR/Docs/debugging-setup.md" ]]; then
    echo "   ✓ Backing up Docs/debugging-setup.md"
    cp "$REPO_DIR/Docs/debugging-setup.md" "$BACKUP_DIR/"
    rm "$REPO_DIR/Docs/debugging-setup.md"
    echo "   ✓ Removed Docs/debugging-setup.md"
  fi
fi

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📋 Summary:"
echo "   • Removed Policyr tmux session script"
echo "   • Removed zsh/policyrAlias.zsh (policyr tmux alias and dev aliases"
echo "     like jstest/phinx/phpunit)"
echo "   • Removed hardcoded machine paths (ToWinBook)"
echo ""
echo "💾 Backups saved to: $BACKUP_DIR"
echo "   (Safe to delete this folder after verifying the cleanup)"
echo ""
echo "📝 Next steps:"
echo "   1. Re-run install.sh to symlink cleaned config:"
echo "      cd $REPO_DIR && ./install.sh"
echo ""
echo "   2. Customize for your project:"
echo "      • Edit ~/.zshrc.local to add your project paths"
echo "      • Edit .env.example to add your project secrets"
echo "      • Create a custom tmux session script for your workflow (optional)"
echo "      • Add your own aliases to zsh/ (or create zsh/custom-aliases.zsh)"
echo ""
echo "   3. Update documentation:"
echo "      • Edit Docs/neovim-ide-setup-plan.md to match your setup"
echo "      • Or restore project-workflow.md/debugging-setup.md and customize them"
echo ""
echo "Happy coding! 🚀"
