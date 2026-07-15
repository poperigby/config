# Build the current configuration, and make it the boot default
switch:
    nh os switch .

# Build the current configuration
test:
   nh os test .

# Switch to the current configuration, and show the trace
debug:
    nh os switch . -- --show-trace

# Check if the configuration works
check:
    nix flake check

# Update the flake.lock
update +input="":
    nix flake update {{input}}

# Update the flake.lock, and rebuild the system
upgrade +input="":
    nix flake update {{input}}
    nh os switch .

# Pull from the repository remote and rebuild
sync:
    jj pull
    nh os switch .

# Garbage collect the Nix store
clean:
    nh clean all

# Build my recovery/install ISO
build-iso:
    nix build .#isoConfigurations.skut

flash-nestor disk="/dev/sdc":
    sudo -v
    nix --accept-flake-config build .#installerImages.nestor

    sudo dd \
        if=result/sd-image/nixos-image-nestor-rpi02-kernel.img \
        of={{disk}} \
        bs=4M \
        status=progress \
        conv=fsync

    sync

    sudo mkdir -p /mnt/sdroot
    sudo partprobe {{disk}}
    sudo mount {{disk}}2 /mnt/sdroot

    sudo install -D -m 0400 -o root -g root \
        /var/lib/sops-nix/key.txt \
        /mnt/sdroot/var/lib/sops-nix/key.txt

    sync
    sudo umount /mnt/sdroot
