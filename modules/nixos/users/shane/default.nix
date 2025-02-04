{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.users.shane;
in
{
  options.custom.users.shane.enable = mkEnableOption "Shane user";

  config = mkIf cfg.enable {
    users.users.shane = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."common/users/shane/password".path;
      description = "Shane Wilson";
      extraGroups = [
        "wheel"
      ];
    };

    # Tell Home Manager information about the user
    home-manager.users.shane.home = {
      username = "shane";
      homeDirectory = "/home/shane";
      stateVersion = config.system.stateVersion;
    };

    sops.secrets."common/users/shane/password".neededForUsers = true;
  };
}
