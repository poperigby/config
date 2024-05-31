# TODO: Maybe have user setup SSH keys for cloning repository?

{
    git,
    gum,
    inputs,
    pkgs,
    writeShellScriptBin,
    ...
}:

let
    disko = inputs.disko.packages.${pkgs.system}.default;
in
writeShellScriptBin "installer" ''
# Fail if piped commands fail
set -uo pipefail

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

    return 1
}

# Don't allow running as root. It's dangerous.
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root is dangerous. Please try running again with a regular user."
    exit 1
fi

if ! AGE_KEY_FILE=$(search_up "age-key.txt"); then
    echo "Cannot find 'age-key.txt' in the current or any parent directories."
    echo "Please copy it over and try again."
    exit 1
fi

# Clone my NixOS configuration repository if it's not already there
if [ ! -d "$HOME/config" ]; then
    ${git}/bin/git clone https://codeberg.org/PopeRigby/nixos.git "$HOME/config"
fi

# Ask which system to install
echo "Which system would you like to install?"
TARGET_HOST=$(ls -1 "$HOME/config/systems/x86_64-linux" | ${gum}/bin/gum choose)

# Partition the disk if the user wants to
echo "The following operation will automatically partition and format your disk"
echo "based on the chosen system's Disko configuration."
if ${gum}/bin/gum confirm --default=false "Would you like to partition and format your disk?"; then
    # Confirm the user actually wants to partition the disk
    ${gum}/bin/gum confirm --default=false "Are you sure you want to continue? Disks configured with Disko will be wiped!"

     # Partition and mount disks based on the system's Disko configuration
     sudo ${disko}/bin/disko --mode disko --flake "$HOME/config#$TARGET_HOST"
fi

echo "Copying age-key.txt to /mnt"
sudo mkdir -p /mnt/var/lib/sops-nix
sudo cp "$AGE_KEY_FILE" /mnt/var/lib/sops-nix/

echo "Installing NixOS system"
if sudo nixos-install --flake "$HOME/config#$TARGET_HOST"; then
    echo "Done! Remove your installation media and reboot :)"
    exit 0
else
    echo "Something went wrong during the installation :("
    exit 1
fi
''
