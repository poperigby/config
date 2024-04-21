{ config, lib, pkgs, ... }:

let
    cfg = config.modules.home.gaming;
in
{

    options.modules.home.gaming.enable = lib.mkEnableOption "Enable various programs/tweaks for gaming";

    config = lib.mkIf cfg.enable {
        imports = [
            ./mangohud.nix
        ];

        # MangoHUD, for monitoring hardware and software during gameplay
        modules.home.mangohud.enable = true;

        # Packages
        home.packages = with pkgs; [
            # Choo choo 🚂
            steam
            # For GOG and Epic Games 🤢
            heroic
            # For managing compatibility tools
            protonup-qt
            # Save game backups
            ludusavi
        ];
    };
}
