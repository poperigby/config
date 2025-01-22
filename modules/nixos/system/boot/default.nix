{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.system.boot;
in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  options.custom.system.boot = {
    loader = mkEnableOption "boot settings";
    secureBoot = mkEnableOption "Secure Boot";
  };

  config = mkIf cfg.loader {
    boot = {
      # Lanzaboote replaces the systemd-boot module
      loader = mkIf (!cfg.secureBoot) {
        systemd-boot = {
          enable = true;
          memtest86.enable = true;
        };
        efi.canTouchEfiVariables = true;
      };
      lanzaboote = mkIf cfg.secureBoot {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
      # Fixes the warnings discussed here
      # https://github.com/NixOS/nixpkgs/issues/342082
      initrd.systemd.enable = true;
    };

    # For debugging and troubleshooting Secure Boot
    environment.systemPackages = mkIf cfg.secureBoot [ pkgs.sbctl ];
  };
}
