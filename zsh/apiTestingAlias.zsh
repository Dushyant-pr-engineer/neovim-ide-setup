# PolicyR API Configuration (Local Environment)
#
# Credentials are NOT stored here — this file is committed to git. Export
# PR_USERNAME and PR_PASSWORD in ~/.zshrc.local instead. They're read at
# call-time inside the functions below (this file is auto-sourced by oh-my-zsh
# BEFORE ~/.zshrc.local loads, so reading them at source-time would be empty).
PR_DOMAIN="${PR_DOMAIN:-http://policyreporter.priv}"
PR_COOKIES="${PR_COOKIES:-/tmp/pr_cookies.txt}"

# PolicyR Functions
pr-login() {
    if [[ -z "$PR_USERNAME" || -z "$PR_PASSWORD" ]]; then
        echo "❌ Set PR_USERNAME and PR_PASSWORD in ~/.zshrc.local"
        return 1
    fi

    echo "🔄 Initializing session..."
    curl -s -c "$PR_COOKIES" "$PR_DOMAIN/login" > /dev/null

    echo "🔐 Logging in as $PR_USERNAME..."
    local response=$(curl -s -c "$PR_COOKIES" -b "$PR_COOKIES" \
        -X POST \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "username=$PR_USERNAME&password=$PR_PASSWORD" \
        "$PR_DOMAIN/login")

    if [ $? -eq 0 ]; then
        echo "✅ Login successful! Session saved."
    else
        echo "❌ Login failed!"
        return 1
    fi
}
# Get user-list api
pr-users() {
    if [ ! -f "$PR_COOKIES" ]; then
        echo "❌ No active session. Running auto-login..."
        pr-login || return 1
    fi

    echo "👥 Fetching users..."
    curl -s -b "$PR_COOKIES" \
        -H "Accept: application/json" \
        "$PR_DOMAIN/user" | jq '.' || echo "❌ Failed to fetch users or jq not installed"
}

pr-call-api() {
    if [ ! -f "$PR_COOKIES" ]; then
        echo "❌ No active session. Running auto-login..."
        pr-login || return 1
    fi

    if [ -z "$1" ]; then
        echo "Usage: pr-api <endpoint>"
        echo "Example: pr-api /user"
        return 1
    fi

    curl -s -b "$PR_COOKIES" \
        -H "Accept: application/json" \
        "$PR_DOMAIN$1" | jq '.'
}

pr-api(){
  echo $PR_COOKIES
}

pr-logout() {
    rm -f "$PR_COOKIES"
    echo "🚪 Logged out. Session cleared."
}

# Auto-login and get users in one command
pr-quick() {
    pr-login && pr-users
}

# Quick aliases
alias prl='pr-login'
alias pru='pr-users'
alias pra='pr-api'
alias prq='pr-quick'
alias prlq='pr-call-api'
