# NixOS Configuration

## Setup

### Clone the repository
```bash
git clone git@codeberg.org:PopeRigby/nixos.git
```

### Setup `age`
Copy my `age` private key from Bitwarden to `~/.config/sops/age/keys.txt`

### Build the flake
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```
