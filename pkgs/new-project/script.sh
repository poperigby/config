# Nix substitutes this with the config source that installed the command.
# New projects use templates from that same source revision.
template_source="@template_source@"

usage() {
    cat >&2 <<'EOF'
Usage: new-project <language> <name> [-- <language args...>]

Examples:
  - new-project rust my-cli
  - new-project rust my-lib -- --lib
  - new-project rust my-cli -- --bin --edition 2024
EOF
}

fail() {
    gum log --level error "$*"
    exit 1
}

run_step() {
    local title="$1"
    shift

    gum spin --show-error --show-output --title "$title" -- "$@"
}

# Languages
rust() {
    local name="$1"
    shift

    if [[ -e "$name" ]]; then
        fail "destination already exists: $name"
    fi

    run_step "Creating Cargo project" cargo new --vcs none "$@" "$name"

    (
        cd "$name" || exit

        run_step "Initializing Jujutsu repository" jj git init
        run_step "Adding Nix Rust template"        nix flake init --template "path:${template_source}#rust"
        run_step "Generating Cargo.lock"           cargo generate-lockfile
        run_step "Tracking files"                  jj file track .
        run_step "Allowing direnv"                 direnv allow
    )

    gum log --level info "created rust project: ${name}"
}

main() {
    if [[ $# -lt 1 ]]; then
        usage
        exit 2
    fi

    case "$1" in
        -h | --help | help)
            usage
            exit 0
            ;;
    esac

    if [[ $# -lt 2 ]]; then
        usage
        exit 2
    fi

    local language="$1"
    local name="$2"
    shift 2

    if [[ "${1-}" == "--" ]]; then
        shift
    elif [[ $# -gt 0 ]]; then
        fail "unexpected arguments before --"
    fi

    case "$language" in
        rust)
            rust "$name" "$@"
            ;;
        *)
            fail "unsupported language: ${language}"
            ;;
    esac
}

main "$@"
