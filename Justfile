switch:
    nh os switch .

debug:
    nh os switch . --verbose

update:
    nix flake update

clean:
    nh clean all

build-iso:
    sudo nix build .#nixosConfigurations.iso.config.system.build.isoImage
