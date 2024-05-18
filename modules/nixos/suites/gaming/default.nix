{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    ;

  cfg = config.poperigby.suites.gaming;
in
{
    options.poperigby.suites.gaming = {
        enable = mkEnableOption "Enable gaming programs/tweaks";
        amd.enable = mkEnableOption "Enable AMD specific tweaks";
    };

    config = mkIf cfg.enable (mkMerge [
        {
            nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
                "steam"
                "steam-original"
                "steam-run"
            ];

            # This does some helpful Steam related tweaks (as well as installing Steam)
            programs.steam.enable = true;

            # Enable GameMode to optimize system performance on demand
            programs.gamemode.enable = true;

            # A microcompositor tailored for gaming
            programs.gamescope = {
                enable = true;
                # Add cap_sys_nice capability to the GameScope binary so that it may renice itself
                capSysNice = true;
            };
        }
        # AMD specific options
        (mkIf cfg.amd.enable {
            programs.corectrl = {
                enable = true;
            };
         })
    ]);
}
