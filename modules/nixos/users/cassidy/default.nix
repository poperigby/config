{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    optionals
    ;

  cfg = config.custom.users.cassidy;

  android = config.custom.hardware.android.enable;
  gui = config.custom.suites.gui.enable;
  printing = config.custom.hardware.printing.enable;
  virtualization = config.custom.services.virtualization.enable;
in
{
  options.custom.users.cassidy.enable = mkEnableOption "Cassidy user";

  config = mkIf cfg.enable {
    # Set up me 🙂
    users.users.cassidy = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."common/users/cassidy/password".path;
      description = "Cassidy Wilson";
      extraGroups = [
        "wheel"
      ]
      ++ optionals android [
        "adbusers"
      ]
      ++ optionals gui [
        "i2c"
        "wireshark"
      ]
      ++ optionals printing [
        # Rootless CUPS
        "lp"
      ]
      ++ optionals virtualization [
        "libvirtd"
      ];
    };

    # Tell Home Manager information about the user
    home-manager.users.cassidy.home = {
      username = "cassidy";
      homeDirectory = "/home/cassidy";
      stateVersion = config.system.stateVersion;
    };

    sops.secrets."common/users/cassidy/password".neededForUsers = true;
  };
}
