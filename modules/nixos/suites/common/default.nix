{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.suites.common;
in
{
  options.custom.suites.common.enable = mkEnableOption "common settings";

  config = mkIf cfg.enable {
    boot = {
      # Use the latest version of the Linux kernel
      kernelPackages = pkgs.linuxPackages_latest;
      kernelParams = [
        # https://github.com/NixOS/nixpkgs/issues/312452
        "systemd.mask=systemd-vconsole-setup.service"
        "systemd.mask=dev-tpmrm0.device"
      ];
    };

    custom = {
      nix.enable = true;
      services = {
        envfs.enable = true;
        ld.enable = true;
        smartd.enable = true;
      };
      security = {
        secrets.enable = true;
        sudo.enable = true;
      };
      system = {
        boot.loader = true;
        locale.enable = true;
        zram.enable = true;
      };
      users.enable = true;
    };
  };
}
