#!@bash@
# Runs @exe@ from a writable copy of WolvenKit through the shared runtime launcher.
set -uo pipefail
export PATH="@path@:$PATH"

dataDir="${XDG_DATA_HOME:-$HOME/.local/share}/wolvenkit7"
appDir="$dataDir/app"
mkdir -p "$dataDir"

# WolvenKit writes its settings next to its own .exe, so it runs from a copy.
# Files are copied over the existing tree, which keeps the settings it wrote.
(
    flock 9
    stamp="$appDir/.nix-store-path"
    if [[ ! -f "$stamp" || "$(<"$stamp")" != "@app@" ]]; then
        echo "wolvenkit: copying @app@ to $appDir" >&2
        mkdir -p "$appDir"
        cp -rT --no-preserve=mode,ownership "@app@" "$appDir"
        printf '%s' "@app@" >"$stamp"
    fi
) 9>"$dataDir/.copy.lock"

status=$(mktemp)
trap 'rm -f "$status"' EXIT

args=""
if (($#)); then
    args=$(printf '%q ' "$@")
fi

# The launcher logs to stdout, so its stdout goes to stderr and the
# executable's output arrives on file descriptor 3.
WOLVENKIT_APP="$appDir" \
    WOLVENKIT_EXE="@exe@" \
    WOLVENKIT_ARGS="$args" \
    WOLVENKIT_STATUS="$status" \
    "@launcher@" 3>&1 1>&2

code=$(<"$status")
exit "${code:-1}"
