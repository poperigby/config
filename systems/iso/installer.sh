#!/usr/bin/env bash

# TODO: Maybe have user setup SSH keys for cloning repository?

# Fail if piped commands fail
set -euo pipefail

# Don't allow running as root. It's dangerous.
if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR! Installer script should be run as a regular user"
    exit 1
fi

if [ ! -f age-key.txt ]; then
    echo "Cannot find age-key.txt in the current directory."
    echo "Please copy it over and try again."
    exit 1
fi

# Clone my NixOS configuration repository if it's not already there
if [ ! -d "${HOME}/config" ]; then
    git clone https://codeberg.org/PopeRigby/nixos.git "${HOME}/config"
fi

# Ask which system to install
echo "Which system would you like to install?"
TARGET_HOST=$(ls -1 "${HOME}/config/systems" --ignore "iso" | ${pgks.gum}/bin/gum choose)

# Partition the disk if the user wants to
echo "The following operation will automatically partition and format your disk"
echo "based on the chosen system's Disko configuration."
if ${pkgs.gum}/bin/gum confirm --default=false "Would you like to partition and format your disk?"; then
    # Confirm the user actually wants to partition the disk
    echo                        "           !!!                    WARNING                      !!!           "
    ${pkgs.gum}/bin/gum confirm --default=false "Are you sure you want to continue? Disks configured with Disko will be wiped!"

    # Partition and mount disks based on the system's Disko configuration
     sudo disko --mode disko "${HOME}/config/systems/${TARGET_HOST}/drives.nix"
fi

echo "Copying age-key.txt to /mnt"
sudo mkdir -p /mnt/var/lib/sops-nix
sudo cp age-key.txt /mnt/var/lib/sops-nix/

echo "Installing NixOS system"
sudo nixos-install --flake "${HOME}/config#${TARGET_HOST}"

echo "Done! Remove your installation media and reboot :)"
