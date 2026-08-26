{ ... }:

{
    den.aspects.programs.provides.gpu-screen-recorder = {
        nixos =
            { ... }:
            {
                programs.gpu-screen-recorder.enable = true;
            };

        homeManager =
            {
                lib,
                pkgs,
                ...
            }:
            {
                home.packages = [ pkgs.gpu-screen-recorder-ui ];

                systemd.user.services.gpu-screen-recorder-ui = {
                    Unit = {
                        Description = "GPU Screen Recorder UI daemon";
                        PartOf = [ "graphical-session.target" ];
                        After = [ "graphical-session.target" ];
                    };

                    Service = {
                        ExecStart = "${lib.getExe' pkgs.gpu-screen-recorder-ui "gsr-ui"} launch-daemon";
                        Restart = "on-failure";
                    };

                    Install.WantedBy = [ "graphical-session.target" ];
                };

                xdg.desktopEntries.gpu-screen-recorder = {
                    name = "GPU Screen Recorder";
                    noDisplay = true;
                };

                xdg.configFile."gpu-screen-recorder/config_ui".text = lib.local.gpuScreenRecorder.renderConfigUi {
                    main = {
                        hotkeys_enable_option = "disable_hotkeys";
                        tint_color = "amd";
                        wayland_warning_shown = true;
                    };

                    record.record_options = {
                        codec = "av1";
                        fps = 165;
                    };

                    replay = {
                        turn_on_replay_automatically_mode = "turn_on_at_game_launch";
                        time = 120;

                        record_options = {
                            codec = "av1";
                            audio_track_item = [
                                "false [add_audio_track]"
                                "false device:default_output"
                                "false [add_audio_track]"
                                "false device:default_input"
                            ];
                        };
                    };
                };
            };

        provides.niri.homeManager =
            { lib, pkgs, ... }:
            let
                bind = command: {
                    _props.repeat = false;
                    spawn = [
                        (lib.getExe' pkgs.gpu-screen-recorder-ui "gsr-ui-cli")
                        command
                    ];
                };
            in
            {
                wayland.windowManager.niri.settings.binds = {
                    "Mod+Print" = bind "toggle-show";
                    "Mod+Alt+Print" = bind "toggle-record";
                    "Mod+Shift+Print" = bind "replay-save";
                };
            };
    };
}
