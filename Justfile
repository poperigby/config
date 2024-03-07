rebuild:
    nh os switch .

debug:
    nh os switch . --verbose

update:
    nix flake update

clean:
    nh clean all
