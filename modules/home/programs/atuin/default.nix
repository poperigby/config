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
            };
        };

        sops.secrets."common/users/${user}/atuin_key" = {};
    };
}
