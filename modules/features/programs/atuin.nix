{ den, ... }:
{
    den.aspects.programs.provides.atuin.homeManager.programs.atuin = {
        enable = true;
        enableFishIntegration = true;
        flags = [ "--disable-up-arrow" ];
        settings = {
            enter_accept = true;
            filter_mode_shell_up_key_binding = "session";
            update_check = false;
            style = "compact";
            inline_height = 25;
            show_help = false;
            workspaces = true;
        };
    };
}
