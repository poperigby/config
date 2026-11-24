{ ... }:
{
    den.aspects.programs.provides.claude.homeManager =
        { lib, pkgs, ... }:
        let
            notify = pkgs.writeShellApplication {
                name = "claude-code-notify";
                runtimeInputs = with pkgs; [
                    coreutils
                    jq
                    libnotify
                ];
                runtimeEnv.CLAUDE_CODE_NOTIFY_ICON = ./icon.svg;
                text = builtins.readFile ./notify.sh;
            };
            hook = [
                {
                    hooks = [
                        {
                            type = "command";
                            command = lib.getExe notify;
                        }
                    ];
                }
            ];
        in
        {
            programs.claude-code = {
                enable = true;
                mutableSettings = true;
                settings = {
                    # The Notification hook below handles desktop notifications.
                    preferredNotifChannel = "notifications_disabled";
                    hooks = {
                        Notification = hook;
                        Stop = hook;
                    };
                };
            };
        };
}
