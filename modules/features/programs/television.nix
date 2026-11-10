{ ... }:
{
    den.aspects.programs.provides.television.homeManager =
        { lib, pkgs, ... }:
        {
            # tv-man touches each index it uses, so only unused ones expire.
            systemd.user.tmpfiles.rules = [ "e %C/tv-man - - - 30d" ];

            programs.television = {
                enable = true;
                settings = {
                    default_action = "Enter";
                    ui.use_nerd_font_icons = true;
                };
                channels = {
                    env = {
                        metadata = {
                            name = "env";
                            description = "A channel to select from environment variables";
                        };
                        source = {
                            command = "printenv";
                            output = "{split:=:1..}";
                        };
                        preview.command = "echo '{split:=:1..}'";
                        ui = {
                            layout = "portrait";
                            preview_panel = {
                                size = 20;
                                header = "{split:=:0}";
                            };
                        };
                        keybindings.shortcut = "f3";
                    };
                    man = {
                        metadata = {
                            name = "man";
                            description = "Browse and preview system manual pages";
                            requirements = [
                                "apropos"
                                "man"
                            ];
                        };
                        source.command = lib.getExe pkgs.local.tv-man;
                        preview = {
                            command = "man '{0}{1}'";
                            env.MANWIDTH = "80";
                        };
                        keybindings.enter = "actions:open";
                        actions.open = {
                            description = "Open the selected man page";
                            command = "man '{0}{1}'";
                            mode = "execute";
                        };
                        ui.layout = "portrait";
                    };
                };
            };
        };
}
