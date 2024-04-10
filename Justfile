tmpdir := `mktemp -d`

switch:
    nh os switch .

debug:
    nh os switch . --verbose

update:
    nix flake update

clean:
    nh clean all

build-iso:
    nix build .#nixosConfigurations.iso.config.system.build.isoImage

install hostname ip:
    mkdir -p {{tmpdir}}/var/lib/sops-nix
    cp ./age-key.txt {{tmpdir}}/var/lib/sops-nix
    nix run nixpkgs#nixos-anywhere -- --extra-files {{tmpdir}} --flake '.#{{hostname}}' root@{{ip}}
