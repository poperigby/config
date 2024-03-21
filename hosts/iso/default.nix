{ pkgs, ... }:

{
    imports = [
        ../../common
    ];

    networking.hostName = "iso";

    users.users.root.password = "nixos";

    environment.systemPackages = with pkgs; [
       neovim
       networkmanager
    ];
}
