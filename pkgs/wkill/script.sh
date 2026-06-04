set -xeou pipefail

PID=$(niri msg --json focused-window | jq '.pid')

kill -9 "$PID"
