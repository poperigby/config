{ config, lib, ... }:

let
    cfg = config.poperigby.programs.atuin;
    user = config.snowfallorg.user.name;
in
{
    options.poperigby.programs.atuin.enable = lib.mkEnableOption "Enable atuin";

    config = lib.mkIf cfg.enable {
        programs.atuin = {
            enable = true;
            settings = {
                key_path = config.sops.secrets."common/users/${user}/atuin_key".path;
                # Enable sync v2 by default
                sync.records = true;
                # Immediately execute a command without having to press Enter twice
                enter_accept = true;
                # Only search history from current directory for Up key
                filter_mode_shell_up_key_binding = "host";
            };
        };

        sops.secrets."common/users/${user}/atuin_key" = {};
    };
}
