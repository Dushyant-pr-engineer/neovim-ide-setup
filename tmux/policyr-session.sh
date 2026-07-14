#!/usr/bin/env bash
# Recreates the "policyr" tmux session layout and attaches to it.
#
#   Window "Policyr Code" in ~/src/ops/policyr:
#     ┌───────────────┬────────┐
#     │  nvim         │ claude │
#     └───────────────┴────────┘
#
#   Window "Portal Code" in ~/src/ops/policyr/portal:
#     ┌───────────────┬────────┐
#     │  nvim         │ claude │
#     └───────────────┴────────┘
#
#   Window "Utility & Ops":
#     ┌───────────────┬────────┐
#     │  shell        │ shell  │
#     │  (policyr)    │(portal)│
#     └───────────────┴────────┘
#
# Idempotent: if the session already exists it just attaches, without
# rebuilding the panes.

set -euo pipefail

SESSION="policyr"
DIR="${POLICYR_PATH:-$HOME/src/ops/policyr}"
PORTAL_DIR="$DIR/portal"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    # Window 1: "Policyr Code" - nvim + claude
    tmux new-session -d -s "$SESSION" -n "Policyr Code" -c "$DIR"
    tmux split-window -h -p 28 -t "$SESSION:Policyr Code" -c "$DIR"
    tmux send-keys -t "$SESSION:Policyr Code.2" 'claude' C-m
    tmux send-keys -t "$SESSION:Policyr Code.1" 'nvim' C-m
    tmux select-pane -t "$SESSION:Policyr Code.1"

    # Window 2: "Portal Code" - nvim + claude
    tmux new-window -t "$SESSION" -n "Portal Code" -c "$PORTAL_DIR"
    tmux split-window -h -p 28 -t "$SESSION:Portal Code" -c "$PORTAL_DIR"
    tmux send-keys -t "$SESSION:Portal Code.2" 'claude' C-m
    tmux send-keys -t "$SESSION:Portal Code.1" 'nvim' C-m
    tmux select-pane -t "$SESSION:Portal Code.1"

    # Window 3: "Utility & Ops" - plain shells
    tmux new-window -t "$SESSION" -n "Utility & Ops" -c "$DIR"
    tmux split-window -h -p 30 -t "$SESSION:Utility & Ops" -c "$PORTAL_DIR"
    tmux select-pane -t "$SESSION:Utility & Ops.1"

    # Leave the first window focused
    tmux select-window -t "$SESSION:Policyr Code"
fi

# Attach (or switch, if already inside tmux)
if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$SESSION"
else
    tmux attach-session -t "$SESSION"
fi
