{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.services.ludusavi;
in
{
    options.poperigby.services.ludusavi = {
        enable = lib.mkEnableOption "Enable Ludusavi game backup tool";
    };

    config = lib.mkIf cfg.enable {
        systemd.user.services.ludusavi = {
            enable = true;
            wantedBy = [ "default.target" ];
            description = "Run a game save backup with Ludusavi";
            serviceConfig = {
                Type = "simple";
                ExecStart = "${pkgs.ludusavi}/bin/ludusavi backup";
            };
        };
    };
}
