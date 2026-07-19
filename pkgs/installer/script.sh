set -euo pipefail

CONFIG_DIR="$HOME/config"
AGE_KEY_INSTALL_PATH="/mnt/var/lib/sops-nix/key.txt"
PRIVATE_CONFIG_SECRETS_FILE="${PRIVATE_CONFIG_SECRETS_FILE:-}"

# Bitwarden host items are expected to live in Hosts/<TitleCaseHost> and to
# carry the private AGE key in a custom field named "AGE Key".
BITWARDEN_FOLDER="${BITWARDEN_FOLDER:-Hosts}"
BITWARDEN_ITEM_PREFIX="${BITWARDEN_ITEM_PREFIX:-}"
BITWARDEN_KEY_FIELD="${BITWARDEN_KEY_FIELD:-AGE Key}"

AGE_KEY_FILE=""

# Remove only the temporary AGE key fetched from Bitwarden. A local fallback
# key.txt belongs to the user and must be left alone.
# shellcheck disable=SC2329
cleanup() {
    if [ -n "$AGE_KEY_FILE" ] && [ -f "$AGE_KEY_FILE" ] && [ "${AGE_KEY_FILE#/tmp/}" != "$AGE_KEY_FILE" ]; then
        rm -f "$AGE_KEY_FILE"
    fi
}

trap cleanup EXIT

search_up() {
    local filename=$1
    local current_dir=$PWD

    while [ "$current_dir" != "/" ]; do
        if [ -e "$current_dir/$filename" ]; then
            echo "$current_dir/$filename"
            return 0
        fi

        current_dir=$(dirname "$current_dir")
    done

    echo "Cannot find '$filename' in the current or any parent directories." >&2
    return 1
}

use_local_age_key() {
    if AGE_KEY_FILE=$(search_up "key.txt"); then
        echo "Using local AGE key at $AGE_KEY_FILE"
        return 0
    fi

    echo "Cannot find a local key.txt fallback." >&2
    return 1
}

sops_secrets_file() {
    if [ -n "$PRIVATE_CONFIG_SECRETS_FILE" ] && [ -f "$PRIVATE_CONFIG_SECRETS_FILE" ]; then
        printf "%s\n" "$PRIVATE_CONFIG_SECRETS_FILE"
        return 0
    fi

    if [ -f "$CONFIG_DIR/secrets.yaml" ]; then
        printf "%s\n" "$CONFIG_DIR/secrets.yaml"
        return 0
    fi

    echo "Cannot find secrets.yaml from private-config or $CONFIG_DIR." >&2
    return 1
}

bitwarden_item_name() {
    local target_host=$1
    local first=${target_host:0:1}
    local rest=${target_host:1}

    # Host directories are lowercase, while Bitwarden host items are Title case.
    printf "%s%s%s\n" "$BITWARDEN_ITEM_PREFIX" "${first^^}" "$rest"
}

bitwarden_status() {
    local session=${1:-}
    local status_json

    if [ -n "$session" ]; then
        status_json=$(bw status --session "$session" 2>/dev/null || true)
    else
        status_json=$(bw status 2>/dev/null || true)
    fi

    printf "%s\n" "$status_json" | jq -r '.status // empty' 2>/dev/null || true
}

bitwarden_session() {
    local status

    # Reuse an exported session when possible so the installer does not prompt
    # again after the user has already unlocked Bitwarden.
    if [ -n "${BW_SESSION:-}" ] && [ "$(bitwarden_status "$BW_SESSION")" = "unlocked" ]; then
        printf "%s\n" "$BW_SESSION"
        return 0
    fi

    status=$(bitwarden_status)

    case "$status" in
        unauthenticated)
            echo "Log in to Bitwarden." >&2
            bw login --raw
            ;;
        locked)
            bw unlock --raw
            ;;
        unlocked)
            # bw can be unlocked even when BW_SESSION was not exported. Asking
            # for a raw session here makes later commands explicit.
            bw unlock --raw
            ;;
        *)
            echo "Bitwarden is in unexpected status '$status'." >&2
            return 1
            ;;
    esac
}

bitwarden_folder_id() {
    local session=$1

    bw list folders --search "$BITWARDEN_FOLDER" --session "$session" \
        | jq -r --arg folder "$BITWARDEN_FOLDER" '
            map(select(.name == $folder))
            | .[0].id // empty
        '
}

bitwarden_host_item() {
    local item_name=$1
    local folder_id=$2
    local session=$3

    bw list items --folderid "$folder_id" --search "$item_name" --session "$session" \
        | jq -e --arg name "$item_name" '
            map(select(.name == $name))
            | .[0]
        '
}

extract_age_key() {
    local item_json=$1
    local age_key

    age_key=$(
        printf "%s\n" "$item_json" | jq -r --arg field "$BITWARDEN_KEY_FIELD" '
            (.fields // [])
            | map(select(.name == $field))
            | .[0].value // empty
        '
    )

    if [ -n "$age_key" ]; then
        printf "%s\n" "$age_key"
        return 0
    fi

    printf "%s\n" "$item_json" | jq -r '.notes // empty'
}

write_temp_age_key() {
    local age_key=$1

    if ! printf "%s\n" "$age_key" | grep -q "AGE-SECRET-KEY-"; then
        echo "Bitwarden item does not contain an AGE secret key." >&2
        echo "Expected a custom field named '$BITWARDEN_KEY_FIELD' or note body containing the key." >&2
        return 1
    fi

    AGE_KEY_FILE=$(mktemp)
    printf "%s\n" "$age_key" > "$AGE_KEY_FILE"
    chmod 600 "$AGE_KEY_FILE"
}

fetch_bitwarden_age_key() {
    local target_host=$1
    local session=$2
    local item_name
    local folder_id
    local item_json
    local age_key

    item_name=$(bitwarden_item_name "$target_host")

    echo "Fetching AGE key from Bitwarden item '$item_name' in folder '$BITWARDEN_FOLDER'"
    folder_id=$(bitwarden_folder_id "$session")

    if [ -z "$folder_id" ]; then
        echo "Could not find Bitwarden folder '$BITWARDEN_FOLDER'." >&2
        return 1
    fi

    if ! item_json=$(bitwarden_host_item "$item_name" "$folder_id" "$session"); then
        echo "Could not find Bitwarden item '$item_name' in folder '$BITWARDEN_FOLDER'." >&2
        return 1
    fi

    age_key=$(extract_age_key "$item_json")
    write_temp_age_key "$age_key"
}

provision_age_key() {
    local target_host=$1
    local session

    # Bitwarden is the normal bootstrap path. The local key.txt path is kept as
    # an explicit recovery choice while migrating away from the shared AGE key.
    if gum confirm --default=true "Fetch $target_host AGE key from Bitwarden?"; then
        session=$(bitwarden_session)
        bw sync --session "$session" >/dev/null
        fetch_bitwarden_age_key "$target_host" "$session"
    else
        use_local_age_key
    fi
}

target_drives_file() {
    local target_host=$1
    local drives_file="$CONFIG_DIR/modules/hosts/$target_host/_nixos/drives.nix"

    if [ ! -f "$drives_file" ]; then
        drives_file="$CONFIG_DIR/modules/hosts/$target_host/drives.nix"
    fi

    printf "%s\n" "$drives_file"
}

decrypt_luks_password_if_needed() {
    local target_host=$1
    local drives_file
    local secrets_file

    drives_file=$(target_drives_file "$target_host")

    if [ ! -f "$drives_file" ] || ! grep -q "luks" "$drives_file"; then
        return 0
    fi

    secrets_file=$(sops_secrets_file)

    echo "Copying LUKS password to /tmp/luks_password"
    export SOPS_AGE_KEY_FILE=$AGE_KEY_FILE
    sops --decrypt --extract "['$target_host']['luks_password']" "$secrets_file" > /tmp/luks_password
}

run_disko() {
    echo "The following operation will automatically partition and format your disk"
    echo "based on the chosen system's Disko configuration."

    if gum confirm --default=false "Would you like to partition and format your disk?"; then
        sudo disko \
            --mode destroy,format,mount \
            --yes-wipe-all-disks \
            --flake "$CONFIG_DIR#$TARGET_HOST"
    else
        sudo disko --mode mount --flake "$CONFIG_DIR#$TARGET_HOST"
    fi
}

install_system() {
    echo "Installing NixOS! Please wait..."

    if sudo nixos-install --no-root-password --flake "$CONFIG_DIR#$TARGET_HOST"; then
        echo "Done! Remove your installation media and reboot :)"
        exit 0
    fi

    echo "Something went wrong during the installation :("
    exit 1
}

if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root is dangerous. Please try running again with a regular user."
    exit 1
fi

if [ ! -d "$CONFIG_DIR" ]; then
    git clone https://codeberg.org/PopeRigby/config.git "$CONFIG_DIR"
fi

echo "Which system would you like to install?"
TARGET_HOST=$(find "$CONFIG_DIR/modules/hosts" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort | gum choose)

provision_age_key "$TARGET_HOST"
decrypt_luks_password_if_needed "$TARGET_HOST"
run_disko

echo "Installing AGE key to $AGE_KEY_INSTALL_PATH"
sudo install -Dm600 "$AGE_KEY_FILE" "$AGE_KEY_INSTALL_PATH"

install_system
