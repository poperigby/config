#!/usr/bin/env bash

# Fail if piped commands fail
set -euo pipefail

# Don't allow running as root. It's dangerous.
if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR! Installer script should be run as a regular user"
    exit 1
fi

# Clone my NixOS configuration repository
git clone https://codeberg.org/PopeRigby/nixos.git ${HOME}/nixos

# Ask which system to install
echo "Which system would you like to install?"
TARGET_HOST = $(ls -1 ${HOME}/nixos/hosts/*/default.nix | cut -d'/' -f6 | grep -v iso | gum choose)
