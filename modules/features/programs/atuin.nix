{ ... }:
{
    den.aspects.programs.provides.atuin.homeManager =
        {
            config,
            lib,
            pkgs,
            ...
        }:
        let
            user = config.home.username;
            cat = lib.getExe' pkgs.coreutils "cat";
        in
        {
            programs.atuin = {
                enable = true;
                enableFishIntegration = true;
                flags = [ "--disable-up-arrow" ];
                settings = {
                    key_path = config.sops.secrets."common/users/${user}/atuin/key".path;
                    sync.records = true;
                    enter_accept = true;
                    filter_mode_shell_up_key_binding = "session";
                    update_check = false;
                    style = "compact";
                    inline_height = 25;
                    show_help = false;
                    workspaces = true;
                };
            };

            systemd.user.services.atuin-login = {
                Unit = {
                    Description = "Automatically login to Atuin if not already logged in";
                    After = [ "sops-nix.service" ];
                };
                Install.WantedBy = [ "default.target" ];
                Service = {
                    Type = "oneshot";
                    ExecStart = pkgs.writeShellScript "atuin-login" ''
                        ${lib.getExe pkgs.atuin} login \
                            -k $(${cat} ${config.sops.secrets."common/users/${user}/atuin/key".path}) \
                            -p $(${cat} ${config.sops.secrets."common/users/${user}/atuin/password".path}) \
                            -u $(${cat} ${config.sops.secrets."common/users/${user}/atuin/username".path})
                    '';
                };
            };

            sops.secrets = {
                "common/users/${user}/atuin/key" = { };
                "common/users/${user}/atuin/password" = { };
                "common/users/${user}/atuin/username" = { };
            };
        };
}
