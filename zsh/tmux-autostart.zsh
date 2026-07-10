# Option A: plain custom auto-attach (installed by default via install.sh).
# See README for Option B (Oh-My-Zsh's built-in `tmux` plugin) if you'd
# rather express this as a named OMZ plugin instead.
if [ -z "$TMUX" ] && [ -n "$PS1" ]; then
    tmux attach-session -t dev || tmux new-session -s dev
fi
