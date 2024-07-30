{ config, inputs, lib, pkgs, system, ... }:

let
    cfg = config.poperigby.suites.gaming;
in
{
    options.poperigby.suites.gaming.enable = lib.mkEnableOption "various programs/tweaks for gaming";

    config = lib.mkIf cfg.enable {
        poperigby = {
            programs = {
                # MangoHUD, for monitoring hardware and software during gameplay
                mangohud.enable = true;
            };
            services = {
                # For backing up games
                ludusavi.enable = true;
            };
        };

        # Packages
        home.packages = with pkgs; [
            # For GOG and Epic Games 🤢
            heroic
            # For managing compatibility tools
            protonup-qt
            # For limiting FPS
            libstrangle
            # We want those fancy new OpenMW features
            poperigby.openmw-nightly
            poperigby.openmw-validator
            poperigby.delta-plugin
            # Doom
            doomrunner
            gzdoom
            # Build Engine
            raze
            # Quake
            inputs.vkquake.legacyPackages.${system}.vkquake
        ];
    };
}
