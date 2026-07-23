alias vim="nvim"
alias vi="nvim"
alias v="nvim"

# Open Win book in terminal
alias ToWinBook="cd /Users/dushyant.patel/Library/CloudStorage/OneDrive-Valeris/Career\ growth/Win\ Book"
alias toWinBook="cd /Users/dushyant.patel/Library/CloudStorage/OneDrive-Valeris/Career\ growth/Win\ Book"

# Python 3 usege
alias python="python3 $@"
alias pip="pip3 $@"

# Local Password file
alias allPass="cat $HOME/.pass"
# Saved System password
alias pass="sed -n '2{p;q;}' ~/.pass | tr -d '\n' | pbcopy && echo Password Copied"
# Saved 1Password master password 
alias 1pass="sed -n '12{p;q;}' ~/.pass | tr -d '\n' | pbcopy && echo Password Copied"

# Default Command Overwrites

# Clear Screen
alias c="clear"
# List all the files in changed dir
chpwd() {
    ls -la
}
