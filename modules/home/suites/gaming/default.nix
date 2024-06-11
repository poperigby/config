{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.suites.gaming;
in
{
    options.poperigby.suites.gaming = {
        enable = lib.mkEnableOption "Enable various programs/tweaks for gaming";
        libraryRoots = lib.mkOption {
            type = with lib.types; listOf (attrsOf str);
            description = "A list of game library root directories, to be backed up by Ludusavi";
            example = {
                path = "~/.local/share/Steam";
                store = "steam";
            };
        };
    };

    config = lib.mkIf cfg.enable {
        poperigby = {
            programs = {
                # MangoHUD, for monitoring hardware and software during gameplay
                mangohud.enable = true;
            };
            services = {
                # For backing up games
                ludusavi = {
                    enable = true;
                    settings = {
                        manifest.url = "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
                        roots = cfg.libraryRoots;
                        backup.path = "~/.local/state/backups/ludusavi";
                        restore.path = "~/.local/state/backups/ludusavi";
                    };
                };
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
            # Doom launcher
            doomrunner
        ];
    };
}
