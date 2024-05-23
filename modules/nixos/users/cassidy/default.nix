{ config, lib, ... }:

let
  cfg = config.poperigby.users.cassidy;
in
{
    options.poperigby.users.cassidy.enable = lib.mkEnableOption "Enable Cassidy user";

    config = lib.mkIf cfg.enable {
        sops.secrets."common/users/cassidy/password".neededForUsers = true;

        # Set up me :)
        users.users.cassidy = {
            isNormalUser = true;
            hashedPasswordFile = config.sops.secrets."common/users/cassidy/password".path;
            description = "Cassidy Wilson";
            extraGroups = [ "wheel" ];
        };

        # Tell Home Manager information about the user
        home-manager.users.cassidy.home = {
            username = "cassidy";
            homeDirectory = "/home/cassidy";
        };
    };
}
