set -euo pipefail

temporary_input=""
cleanup() {
    if [[ -n "$temporary_input" ]]; then
        rm -f -- "$temporary_input"
    fi
}
trap cleanup EXIT

if (( $# == 0 )); then
    temporary_input="$(mktemp)"
    cat > "$temporary_input"
    input_file="$temporary_input"
elif (( $# == 1 )) && [[ -f "$1" ]]; then
    temporary_input="$(mktemp)"
    cp -- "$1" "$temporary_input"
    input_file="$temporary_input"
else
    temporary_input="$(mktemp)"
    printf '%s\n' "$@" > "$temporary_input"
    input_file="$temporary_input"
fi

nix eval --impure --expr "builtins.fromTOML (builtins.readFile $input_file)" | nixfmt --indent 4 -
