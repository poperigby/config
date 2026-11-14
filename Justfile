# Build the current configuration, and make it the boot default
switch:
    nh os switch .

boot:
    nh os boot .

# Build the current configuration
test:
   nh os test .

# Write the flake.nix based on flake-file inputs
write-flake:
    nix run .#write-flake

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

flash-nestor disk="/dev/sdc":
    sudo -v
    nix build .#images.aarch64-linux.nestor

    sudo dd \
        if=result/sd-image/nixos-image-rpi02-kernel.img \
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
    sudo rm result/sd-image/nixos-image-rpi02-kernel.img

update-nestor:
    nh os switch .#nestor \
        --target-host cassidy@nestor \
        --elevation-strategy sudo
