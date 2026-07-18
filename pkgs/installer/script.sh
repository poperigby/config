set -euo pipefail

CONFIG_DIR="$HOME/config"
AGE_KEY_INSTALL_PATH="/mnt/var/lib/sops-nix/key.txt"
BITWARDEN_ITEM_PREFIX="${BITWARDEN_ITEM_PREFIX:-}"
BITWARDEN_KEY_FIELD="${BITWARDEN_KEY_FIELD:-AGE Key}"
BITWARDEN_FOLDER="${BITWARDEN_FOLDER:-Hosts}"

AGE_KEY_FILE=""

# shellcheck disable=SC2329
cleanup() {
    if [ -n "$AGE_KEY_FILE" ] && [ -f "$AGE_KEY_FILE" ] && [ "${AGE_KEY_FILE#/tmp/}" != "$AGE_KEY_FILE" ]; then
        rm -f "$AGE_KEY_FILE"
    fi
}

trap cleanup EXIT

# Search the current directory and any parent directories for a file
search_up() {
    local filename=$1
    local current_dir=$PWD

    # Loop until the root directory is reached
    while [ "$current_dir" != "/" ]; do
        # Check if the file exists in the current directory
        if [ -e "$current_dir/$filename" ]; then
          echo "$current_dir/$filename"
          return 0
        fi
        # Move to the parent directory
        current_dir=$(dirname "$current_dir")
    done

    echo "Cannot find '$filename' in the current or any parent directories."
    return 1
}

use_local_age_key() {
    if AGE_KEY_FILE=$(search_up "key.txt"); then
        echo "Using local AGE key at $AGE_KEY_FILE"
        return 0
    fi

    echo "Cannot find a local key.txt fallback."
    return 1
}

bitwarden_item_name() {
    local target_host=$1
    local first=${target_host:0:1}
    local rest=${target_host:1}

    printf "%s%s%s\n" "$BITWARDEN_ITEM_PREFIX" "${first^^}" "$rest"
}

bitwarden_session() {
    if [ -n "${BW_SESSION:-}" ] && bw sync --session "$BW_SESSION" >/dev/null 2>&1; then
        echo "$BW_SESSION"
        return 0
    fi

    if ! bw login --check >/dev/null 2>&1; then
        echo "Log in to Bitwarden." >&2
        bw login >&2
    fi

    bw unlock --raw
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
    folder_id=$(
        bw list folders --search "$BITWARDEN_FOLDER" --session "$session" \
            | jq -r --arg folder "$BITWARDEN_FOLDER" '
                map(select(.name == $folder))
                | .[0].id // empty
            '
    )

    if [ -z "$folder_id" ]; then
        echo "Could not find Bitwarden folder '$BITWARDEN_FOLDER'." >&2
        return 1
    fi

    item_json=$(
        bw list items --folderid "$folder_id" --search "$item_name" --session "$session" \
            | jq -e --arg name "$item_name" '
                map(select(.name == $name))
                | .[0]
            '
    )

    age_key=$(
        echo "$item_json" | jq -r --arg field "$BITWARDEN_KEY_FIELD" '
            (.fields // [])
            | map(select(.name == $field))
            | .[0].value // empty
        '
    )

    if [ -z "$age_key" ]; then
        age_key=$(echo "$item_json" | jq -r '.notes // empty')
    fi

    if ! printf "%s\n" "$age_key" | grep -q "AGE-SECRET-KEY-"; then
        echo "Bitwarden item '$item_name' does not contain an AGE secret key."
        echo "Expected a custom field named '$BITWARDEN_KEY_FIELD' or note body containing the key."
        return 1
    fi

    AGE_KEY_FILE=$(mktemp)
    printf "%s\n" "$age_key" > "$AGE_KEY_FILE"
    chmod 600 "$AGE_KEY_FILE"
}

provision_age_key() {
    local target_host=$1
    local session

    if gum confirm --default=true "Fetch $target_host AGE key from Bitwarden?"; then
        session=$(bitwarden_session)
        bw sync --session "$session" >/dev/null
        fetch_bitwarden_age_key "$target_host" "$session"
    else
        use_local_age_key
    fi
}

# Don't allow running as root. It's dangerous.
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root is dangerous. Please try running again with a regular user."
    exit 1
fi

# Clone my NixOS configuration repository if it's not already there
if [ ! -d "$CONFIG_DIR" ]; then
    git clone https://codeberg.org/PopeRigby/config.git "$CONFIG_DIR"
fi

# Ask which system to install
echo "Which system would you like to install?"
TARGET_HOST=$(find "$CONFIG_DIR/modules/hosts" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort | gum choose)

provision_age_key "$TARGET_HOST"

# Put the host's LUKS password in /tmp/luks_password if it uses LUKS
DRIVES_FILE="$CONFIG_DIR/modules/hosts/$TARGET_HOST/_nixos/drives.nix"
if [ ! -f "$DRIVES_FILE" ]; then
    DRIVES_FILE="$CONFIG_DIR/modules/hosts/$TARGET_HOST/drives.nix"
fi

if [ -f "$DRIVES_FILE" ] && grep -q "luks" "$DRIVES_FILE"; then
    echo "Copying LUKS password to /tmp/luks_password"
    export SOPS_AGE_KEY_FILE=$AGE_KEY_FILE
    sops --decrypt --extract "['$TARGET_HOST']['luks_password']" "$CONFIG_DIR/secrets.yaml" > /tmp/luks_password
fi

# Partition the disk if the user wants to
echo "The following operation will automatically partition and format your disk"
echo "based on the chosen system's Disko configuration."
if gum confirm --default=false "Would you like to partition and format your disk?"; then
     # Partition and mount disks based on the system's Disko configuration
     sudo disko \
         --mode destroy,format,mount \
         --yes-wipe-all-disks \
         --flake "$CONFIG_DIR#$TARGET_HOST"
else
     # Mount disks based on the system's Disko configuration
     sudo disko --mode mount --flake "$CONFIG_DIR#$TARGET_HOST"
fi

echo "Installing AGE key to $AGE_KEY_INSTALL_PATH"
sudo install -Dm600 "$AGE_KEY_FILE" "$AGE_KEY_INSTALL_PATH"

echo "Installing NixOS! Please wait..."
if sudo nixos-install --no-root-password --flake "$CONFIG_DIR#$TARGET_HOST"; then
    echo "Done! Remove your installation media and reboot :)"
    exit 0
else
    echo "Something went wrong during the installation :("
    exit 1
fi
