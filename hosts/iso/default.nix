{ ... }:

{
    imports = [
        ../../common
    ];

    # We don't need backups for a live ISO
    common.backups.enable = false;

    networking.hostname = "iso";

    users.extraUsers.root.password = "nixos";
}
