rebuild:
    sudo nixos-rebuild switch --flake .#haddock

debug:
    sudo nixos-rebuild switch --flake .#haddock --show-trace --verbose

update:
    nix flake update

gc:
    sudo nix-collect-garbage --delete-old
