rebuild:
    sudo nixos-rebuild switch

debug:
    sudo nixos-rebuild switch --show-trace --verbose

update:
    nix flake update

gc:
    sudo nix-collect-garbage --delete-old
