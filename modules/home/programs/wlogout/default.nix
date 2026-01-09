{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib)
        getExe'
        mkEnableOption
        mkIf
        ;

    cfg = config.custom.programs.wlogout;
in
{
    options.custom.programs.wlogout.enable = mkEnableOption "logout menu";

    config = mkIf cfg.enable {
        programs.wlogout = {
            enable = true;
            layout = [
                {
                    label = "logout";
                    text = "Logout";
                    action = "${getExe' pkgs.sway "swaymsg"} exit";
                    keybind = "l";
                }
                {
                    label = "shutdown";
                    text = "Shutdown";
                    action = "systemctl poweroff";
                    keybind = "s";
                }
                {
                    label = "reboot";
                    text = "Reboot";
                    action = "systemctl reboot";
                    keybind = "r";
                }
            ];
            style = # css
                ''
                    window {
                        background-color: rgba(40, 40, 40, 0.5);
                    }

                    button {
                        color: #ebdbb2;
                        font-size: 16px;
                        background-color: #3c383c;
                        border-style: none;
                        background-repeat: no-repeat;
                        background-position: center;
                        background-size: 35%;
                        border-radius: 20px;
                        margin: 100px 5px;
                        text-shadow: 0px 0px;
                        box-shadow: 0px 0px;
                    }

                    button:focus, button:active, button:hover {
                        background-color: #83a598;
                        outline-style: none;
                    }

                    #logout {
                        background-image: image(url("${./icons/logout.png}"));
                    }

                    #shutdown {
                        background-image: image(url("${./icons/shutdown.png}"));
                    }

                    #reboot {
                        background-image: image(url("${./icons/reboot.png}"));
                    }
                '';
        };
    };
}
