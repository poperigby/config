alias sw := switch

build-iso:
    nix build .#isoConfigurations.minimal

check:
    nix flake check

clean:
    nh clean all

debug:
    nh os switch . --verbose

switch:
    nh os switch .

update:
    nix flake update
