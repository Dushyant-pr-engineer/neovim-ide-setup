# Option A: plain custom auto-attach (installed by default via install.sh).
# See README for Option B (Oh-My-Zsh's built-in `tmux` plugin) if you'd
# rather express this as a named OMZ plugin instead.
#
# IMPORTANT: this file's contents get PREPENDED to the very top of ~/.zshrc
# by install.sh (see the TMUX_MARKER logic in Step 3) rather than dropped
# into $ZSH_CUSTOM. A $ZSH_CUSTOM file is sourced by `source $ZSH/oh-my-zsh.sh`,
# which runs after Powerlevel10k's instant-prompt block has already started
# buffering console output — tmux needs to take over the tty directly at
# attach/create time, so running this late causes
# "open terminal failed: not a terminal".
#
# Deliberately NOT using `exec`: if tmux ever fails to start (missing TPM on
# first run, a bad tmux.conf directive, etc.), falling through leaves you in
# a normal interactive shell instead of silently closing the terminal tab.
if [[ -z "$TMUX" && -o interactive && -t 1 ]]; then
    tmux attach-session -t dev 2>/dev/null || tmux new-session -s dev
fi
