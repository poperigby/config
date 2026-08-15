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
    input_file="$1"
else
    temporary_input="$(mktemp)"
    printf '%s\n' "$*" > "$temporary_input"
    input_file="$temporary_input"
fi

yaml2nix "$input_file" | nixfmt --indent 4 -
