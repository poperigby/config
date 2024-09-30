# Settings relevant to every home

{ config, lib, ... }:

{
    options.poperigby.configDir = lib.mkOption {
        type = lib.types.path;
        description = "Location of my flake configuration repository";
        default = "${config.home.homeDirectory}/Projects/nixos";
        example = "${config.home.homeDirectory}/config";
        apply = toString;
    };

    config = {
        # Make programs use XDG directories whenever supported
        home.preferXdgDirectories = true;

        # Nicely reload system units when changing configurations
        systemd.user.startServices = "sd-switch";
    };
}
