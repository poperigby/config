{ ... }:
{
    den.aspects.programs.provides.television.homeManager =
        { ... }:
        {
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
                };
            };
        };
}
