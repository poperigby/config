{ config, inputs, lib, ... }:

let
    cfg = config.poperigby.services.flameshot;
    colors = config.colorScheme.palette;
in
{
    options.poperigby.services.flameshot.enable = lib.mkEnableOption "Enable Flameshot screenshot tool";

    imports = [ inputs.nix-colors.homeManagerModules.default ];

    config = lib.mkIf cfg.enable {
        services.flameshot = {
            enable = true;
            settings = {
                General = {
                    savePath = "${config.xdg.userDirs.pictures}/Screenshots";
                    disabledTrayIcon = true;
                    showStartupLaunchMessage = false;
                    # Colors
                    uiColor = "#${colors.base0A}";
                };
            };
        };
    };
}
