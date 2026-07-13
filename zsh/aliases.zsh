alias vim="nvim"
alias vi="nvim"
alias v="nvim"

# tmux — attach manually (terminal no longer auto-attaches on launch).
# `policyr` attaches to the saved PolicyR session, recreating its
# nvim / shell / claude layout if it isn't running yet.
alias policyr="$HOME/src/neovim-ide-setup/tmux/policyr-session.sh"

# Python 3 usege
alias python="python3 $@"
alias pip="pip3 $@"

# Utility command alias
alias c="clear"

# Local Password
alias pass="cat $HOME/.pass"