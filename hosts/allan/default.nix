{ ... }:

{
    imports = [
        ../../common
        ./disks.nix
    ];

    # Define hostname
    networking.hostName = "allan";
}
