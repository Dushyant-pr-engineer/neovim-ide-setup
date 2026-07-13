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

# 2. Remove Policyr-specific development aliases
if [[ -f "$REPO_DIR/zsh/devAlias.zsh" ]]; then
  echo "   ✓ Backing up zsh/devAlias.zsh"
  cp "$REPO_DIR/zsh/devAlias.zsh" "$BACKUP_DIR/"
  rm "$REPO_DIR/zsh/devAlias.zsh"
  echo "   ✓ Removed zsh/devAlias.zsh"
fi

# 3. Remove hardcoded ToWinBook aliases from generalAlias.zsh
if [[ -f "$REPO_DIR/zsh/generalAlias.zsh" ]]; then
  echo "   ✓ Cleaning up zsh/generalAlias.zsh"

  # Backup before modification
  cp "$REPO_DIR/zsh/generalAlias.zsh" "$BACKUP_DIR/"

  # Remove ToWinBook lines (both cases)
  sed -i.bak '/^alias ToWinBook=/d; /^alias toWinBook=/d' "$REPO_DIR/zsh/generalAlias.zsh"
  rm "$REPO_DIR/zsh/generalAlias.zsh.bak"

  echo "   ✓ Removed hardcoded ToWinBook aliases"
fi

# 4. Remove policyr alias from main aliases if it exists
if [[ -f "$REPO_DIR/zsh/aliases.zsh" ]]; then
  if grep -q "alias policyr=" "$REPO_DIR/zsh/aliases.zsh"; then
    echo "   ✓ Backing up zsh/aliases.zsh"
    cp "$REPO_DIR/zsh/aliases.zsh" "$BACKUP_DIR/"

    # Remove policyr alias and its definition
    sed -i.bak '/^# Attach to policyr session/d; /^alias policyr=/d' "$REPO_DIR/zsh/aliases.zsh"
    rm "$REPO_DIR/zsh/aliases.zsh.bak"

    echo "   ✓ Removed policyr session alias"
  fi
fi

# 5. Update .env.example to remove Policyr-specific secrets
if [[ -f "$REPO_DIR/.env.example" ]]; then
  echo "   ✓ Cleaning up .env.example"

  cp "$REPO_DIR/.env.example" "$BACKUP_DIR/"

  # Remove Policyr-specific credentials (comment them out or remove)
  sed -i.bak '/^PR_USERNAME=/d; /^PR_PASSWORD=/d; /^DOCKET_PATH=/d' "$REPO_DIR/.env.example"
  rm "$REPO_DIR/.env.example.bak"

  echo "   ✓ Removed Policyr-specific credentials from .env.example"
fi

# 6. Optional: Remove project-specific docs
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
echo "   • Removed Policyr development aliases (jstest, phpunit, phinx, etc.)"
echo "   • Removed hardcoded machine paths (ToWinBook)"
echo "   • Cleaned up .env.example"
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
