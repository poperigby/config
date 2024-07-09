{ config, lib, pkgs, ... }:

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
                key_path = config.sops.secrets."common/users/${user}/atuin/key".path;
                # Enable sync v2 by default
                sync.records = true;
                # Immediately execute a command without having to press Enter twice
                enter_accept = true;
                # Only search history from current directory for Up key
                filter_mode_shell_up_key_binding = "host";
            };
        };

        # Automatically login if not already logged in
        systemd.user.services.atuin-login = {
            Unit = {
                Description = "Automatically login to Atuin if not already logged in";
                After = [ "sops-nix.service" ];
            };
            Install.WantedBy = [ "multi-user.target" ];
            Service = {
                Type = "oneshot";
                ExecStart = let
                    cat = "${pkgs.coreutils}/bin/cat";
                in pkgs.writeShellScript "atuin-login" ''
                    ${pkgs.atuin}/bin/atuin login \
                        -k $(${cat} ${config.sops.secrets."common/users/${user}/atuin/key".path}) \
                        -p $(${cat} ${config.sops.secrets."common/users/${user}/atuin/password".path}) \
                        -u $(${cat} ${config.sops.secrets."common/users/${user}/atuin/username".path})
                '';
            };
        };

        sops.secrets = {
            "common/users/${user}/atuin/key" = {};
            "common/users/${user}/atuin/password" = {};
            "common/users/${user}/atuin/username" = {};
        };
    };
}
