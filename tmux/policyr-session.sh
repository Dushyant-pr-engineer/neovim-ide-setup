#!/usr/bin/env bash
# Recreates the "policyr" tmux session layout and attaches to it.
#
#   Window "nvim" in ~/src/ops/policyr:
#     ┌───────────────┬──────┐
#     │  nvim (top)   │      │
#     ├───────────────┤ claude
#     │  shell (bot)  │      │
#     └───────────────┴──────┘
#
# Idempotent: if the session already exists it just attaches, without
# rebuilding the panes.

set -euo pipefail

SESSION="policyr"
DIR="$HOME/src/ops/policyr"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    # Left column, top pane: nvim
    tmux new-session -d -s "$SESSION" -n nvim -c "$DIR"

    # Narrow right column (~19 cols): Claude Code
    tmux split-window -h -l 19 -t "$SESSION:nvim" -c "$DIR"
    tmux send-keys -t "$SESSION:nvim.2" 'claude' C-m

    # Split the left column: bottom pane (~11 rows) is a plain shell
    tmux split-window -v -l 11 -t "$SESSION:nvim.1" -c "$DIR"

    # Launch nvim in the top-left pane and leave it focused
    tmux send-keys -t "$SESSION:nvim.1" 'nvim' C-m
    tmux select-pane -t "$SESSION:nvim.1"
fi

# Attach (or switch, if already inside tmux)
if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$SESSION"
else
    tmux attach-session -t "$SESSION"
fi
