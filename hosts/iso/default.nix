{ ... }:

{
    imports = [
        ../../common
    ];

    networking.hostname = "iso";

    users.extraUsers.root.password = "nixos";
}
