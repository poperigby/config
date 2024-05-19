alias sw := switch

switch:
    nh os switch .

debug:
    nh os switch . --verbose

update:
    nix flake update

clean:
    nh clean all

build-iso:
    nix build .#isoConfigurations.minimal
