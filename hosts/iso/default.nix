{ pkgs, ... }:

{
    imports = [
        ../../common
    ];

    networking.hostName = "iso";

    users.extraUsers.root.password = "nixos";

    environment.systemPackages = with pkgs; [
       neovim
       networkmanager
    ];
}
