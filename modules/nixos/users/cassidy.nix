{ config, lib, ... }:

let
  cfg = config.poperigby.users.cassidy;
in
{
    options.poperigby.users.cassidy.enable = lib.mkEnableOption "Enable Cassidy user";

    config = lib.mkIf cfg.enable {
        sops.secrets."common/passwords/cassidy".neededForUsers = true;

        # Set up me :)
        users.users.cassidy = {
            isNormalUser = true;
            hashedPasswordFile = config.sops.secrets."common/passwords/cassidy".path;
            description = "Cassidy Wilson";
            extraGroups = [ "wheel" ];
        };
    };
}
