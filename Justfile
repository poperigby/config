# Switch to the current configuration
switch:
    nh os switch .

# Switch to the current configuration with verbose output
debug:
    nh os switch . --verbose

# Check if the configuration works
check:
    nix flake check

# Update the flake.lock, check if it still works, and add it to the git index
update:
    nix flake update
    # Make sure the configuration still works
    nix flake check
    git add flake.*

# Garbage collect the Nix store
clean:
    nh clean all

# Build my recovery/install ISO
build-iso:
    nix build .#isoConfigurations.minimal
