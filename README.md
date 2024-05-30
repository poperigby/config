# NixOS Configuration

This repository uses [Snowfall Lib](https://github.com/snowfallorg/lib).

Imperative steps are hardware documentation are located in the [wiki](https://codeberg.org/PopeRigby/nixos/wiki).

## Setup

### Clone the repository
```bash
git clone git@codeberg.org:PopeRigby/nixos.git
```

### Setup `age`
Copy my `age` private key from Bitwarden to `/var/lib/sops-nix/age-key.txt`

### Build the flake
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```
