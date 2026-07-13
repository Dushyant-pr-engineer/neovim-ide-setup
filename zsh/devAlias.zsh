DOCKER_PATH="/opt/pr/docker"
PHPUNIT_OPTIONS="--testdox --colors=always"
PORTAL_PATH="${POLICYR_PATH:-$HOME/src/ops/policyr}/portal"

# Run phinx commands
alias phinx="$DOCKER_PATH/phinx.sh $@"

# Run PHP unit tests
alias phpunit="$DOCKER_PATH/phpunit.sh $PHPUNIT_OPTIONS $*"

alias pfunit="$DOCKER_PATH/phpunit.sh $PHPUNIT_OPTIONS --filter $1 $*"

# Watch for error logs in policyr
alias policyr_error_log="docker exec -it policyr tail -f /var/log/policyr_error_log"

# Xdebug logs
alias xdebug_log="docker exec -it policyr tail -f /var/log/xdebug.log"

# Run JS unit tests
alias jstest="cd $PORTAL_PATH && npm run test $*"

# Set default fusion auth users from DB
alias create-fusionauth-default="$DOCKET_PATH/zend.sh create-fusionauth-default --delete=1 --createusers=all --verified=1 --defaultpassword=1"

# Open Win book in terminal
alias ToWinBook="cd /Users/dushyant.patel/Library/CloudStorage/OneDrive-Valeris/Career\ growth/Win\ Book"
alias toWinBook="cd /Users/dushyant.patel/Library/CloudStorage/OneDrive-Valeris/Career\ growth/Win\ Book"