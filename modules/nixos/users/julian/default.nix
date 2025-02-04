{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.users.julian;
in
{
  options.custom.users.julian.enable = mkEnableOption "Julian user";

  config = mkIf cfg.enable {
    users.users.julian = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."common/users/julian/password".path;
      description = "Julian Wilson";
      extraGroups = [
        "wheel"
      ];
    };

    # Tell Home Manager information about the user
    home-manager.users.julian.home = {
      username = "julian";
      homeDirectory = "/home/julian";
      stateVersion = config.system.stateVersion;
    };

    sops.secrets."common/users/julian/password".neededForUsers = true;
  };
}
