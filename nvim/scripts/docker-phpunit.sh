#!/usr/bin/env bash
# Runs phpunit inside a docker container instead of on the host, for projects
# where the app (and its vendor/) only exists inside the container.
#
# neotest-phpunit invokes this with host-absolute paths (test file, --log-junit
# tmp file). We translate the test file path from host to container path, run
# phpunit inside the container, then docker cp the junit result back out so
# neotest can read it from the host path it expects.
set -uo pipefail

CONTAINER_NAME="${NEOTEST_DOCKER_CONTAINER:-policyr}"
HOST_ROOT="${NEOTEST_DOCKER_HOST_ROOT:-${POLICYR_PATH:-$HOME/src/ops/policyr}}"
CONTAINER_ROOT="${NEOTEST_DOCKER_CONTAINER_ROOT:-/opt/pr/policyr}"

log_junit_host=""
args=()
for a in "$@"; do
    case "$a" in
        --log-junit=*)
            log_junit_host="${a#--log-junit=}"
            args+=("--log-junit=/tmp/$(basename "$log_junit_host")")
            ;;
        "$HOST_ROOT"/*)
            args+=("${CONTAINER_ROOT}${a#"$HOST_ROOT"}")
            ;;
        *)
            args+=("$a")
            ;;
    esac
done

docker exec -w "$CONTAINER_ROOT" "$CONTAINER_NAME" ./vendor/bin/phpunit "${args[@]}"
status=$?

if [ -n "$log_junit_host" ]; then
    docker cp "$CONTAINER_NAME:/tmp/$(basename "$log_junit_host")" "$log_junit_host" 2>/dev/null
    # PHPUnit records container-side file paths in the junit XML; neotest matches
    # test results against host-side paths, so translate them back or every
    # result silently fails to match and shows as failed regardless of outcome.
    if [ -f "$log_junit_host" ]; then
        sed -i '' "s#${CONTAINER_ROOT}#${HOST_ROOT}#g" "$log_junit_host"
    fi
fi

exit "$status"
