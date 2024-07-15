# Switch to the current configuration
switch:
    nh os switch .

# Switch to the current configuration, and show the trace
debug:
    nh os switch . -- --show-trace

# Check if the configuration works
check:
    nix flake check

# Update the flake.lock, check if it still works, and add it to the git index
update:
    nix flake update
    # Make sure the configuration still works
    nix flake check
    git add flake.*

# Update the flake.lock, and rebuild the system
upgrade:
    nix flake update
    nh os switch .

# Pull from the repository remote and rebuild
sync:
    git pull
    nh os switch .

# Garbage collect the Nix store
clean:
    nh clean all

# Build my recovery/install ISO
build-iso:
    nix build .#isoConfigurations.skut
