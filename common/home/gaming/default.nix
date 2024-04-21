{ config, lib, pkgs, ... }:

let
    cfg = config.common.home.gaming;
in
{

    options.common.home.gaming.enable = lib.mkEnableOption "Enable various programs/tweaks for gaming";

    config = lib.mkIf cfg.enable {
        imports = [
            ./mangohud.nix
        ];

        # MangoHUD, for monitoring hardware and software during gameplay
        common.home.mangohud.enable = true;

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
