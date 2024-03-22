#!/usr/bin/env bash

# Fail if piped commands fail
set -euo pipefail

# Don't allow running as root. It's dangerous.
if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR! Installer script should be run as a regular user"
    exit 1
fi

# Clone my NixOS configuration repository if it's not already there
if [ -d "$HOME/nixos" ]; then
    git clone https://codeberg.org/PopeRigby/nixos.git ${HOME}/nixos
fi

# Partition the disk if the user wants to
echo "The following operation will automatically partition and format your disk"
echo "to have an EFI and root partition, formatted with EXT4."
if [ $(gum confirm "Would you like to partition and format your disk?") -eq 0 ]; then
    # Choose which disk to partition
    echo "Which disk would you like to partition and install to?"
    DISK = "/dev/$(lsblk -o NAME,TYPE | grep 'disk' | awk '{print $1}' | gum choose)"

    # Confirm the user actually wants to partition the disk
    echo        "          ⚠️⚠️⚠️                   WARNING              ⚠️⚠️⚠️           "
    gum confirm "Are you sure you want to continue? The selected disk will be wiped!"
fi

# Ask which system to install
echo "Which system would you like to install?"
TARGET_HOST = $(ls -1 ${HOME}/nixos/hosts/*/default.nix | cut -d'/' -f6 | grep -v iso | gum choose)
