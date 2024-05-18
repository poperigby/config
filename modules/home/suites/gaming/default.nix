{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.suites.gaming;
in
{
    options.poperigby.suites.gaming.enable = lib.mkEnableOption "Enable various programs/tweaks for gaming";

    config = lib.mkIf cfg.enable {
        # MangoHUD, for monitoring hardware and software during gameplay
        # common.home.gaming.mangohud.enable = true;

        # Packages
        home.packages = with pkgs; [
            # For GOG and Epic Games 🤢
            heroic
            # For managing compatibility tools
            protonup-qt
            # Save game backups
            ludusavi
        ];
    };
}
