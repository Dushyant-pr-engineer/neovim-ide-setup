#!/usr/bin/env bash
# Recreates the "policyr" tmux session layout and attaches to it.
#
#   Window "Policyr Code" in ~/src/ops/policyr:
#     ┌───────────────┐
#     │  nvim         │
#     └───────────────┘
#
#   Window "Portal Code" in ~/src/ops/policyr/portal:
#     ┌───────────────┐
#     │  nvim         │
#     └───────────────┘
#
#   Window "Utility & Ops":
#     ┌──────────┬──────────────────────┐
#     │  shell   │                      │
#     │ (docker) │        shell         │
#     ├──────────┤       (portal,       │
#     │  shell   │      npm start)      │
#     │(policyr) │                      │
#     └──────────┴──────────────────────┘
#
# Idempotent: if the session already exists it just attaches, without
# rebuilding the panes.

set -euo pipefail

SESSION="policyr"
DIR="${POLICYR_PATH:-$HOME/src/ops/policyr}"
PORTAL_DIR="$DIR/portal"
DOCKER_DIR="${DOCKER_PATH:-$HOME/src/ops/docker}"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    # Window 1: "Policyr Code" - nvim
    tmux new-session -d -s "$SESSION" -n "Policyr Code" -c "$DIR"
    tmux send-keys -t "$SESSION:Policyr Code" 'nvim' C-m

    # Window 2: "Portal Code" - nvim
    tmux new-window -t "$SESSION" -n "Portal Code" -c "$PORTAL_DIR"
    tmux send-keys -t "$SESSION:Portal Code" 'nvim' C-m

    # Window 3: "Utility & Ops" - docker shell, policyr shell, portal dev server
    tmux new-window -t "$SESSION" -n "Utility & Ops" -c "$DOCKER_DIR"
    tmux split-window -h -p 30 -t "$SESSION:Utility & Ops" -c "$PORTAL_DIR"
    tmux split-window -v -p 70 -t "$SESSION:Utility & Ops.1" -c "$DIR"
    tmux send-keys -t "$SESSION:Utility & Ops.3" 'npm start' C-m
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
