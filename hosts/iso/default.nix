{ ... }:

{
    imports = [
        ../../common
    ];

    networking.hostName = "iso";

    users.extraUsers.root.password = "nixos";
}
