{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.services.lact;
    settingsFormat = pkgs.formats.yaml {};

    configFile = if cfg.configFile == null then
        settingsFormat.generate "config.yaml" cfg.settings
    else
        cfg.configFile;
    in
{
    options.poperigby.services.lact = {
        enable = lib.mkEnableOption "Enable Lact for controlling AMD GPUs";
        configFile = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = lib.mdDoc ''
                Path to a Lact `config.yaml`. Mutually exclusive with the `settings` option.
            '';
        };
        settings = lib.mkOption {
            type = settingsFormat.type;
            default = {};
            description = lib.mdDoc ''
                Ludusavi configuration as an attribute set.
            '';
        };
    };

    config = lib.mkIf cfg.enable {
        assertions = [
            {
                assertion = (cfg.settings != {}) != (cfg.configFile != null);
                message = "The `settings` and `configFile` options are mutually exclusive.";
            }
        ];

        environment.etc."lact/config.yaml".source = configFile;

        systemd.services.lact = {
            wantedBy = [ "multi-user.target" ];
            unitConfig = {
                Description = "AMD GPU Control Daemon";
                After = [ "multi-user.target" ];
            };
            serviceConfig = {
                ExecStart = "${pkgs.lact}/bin/lact daemon";
            };
        };
    };
}
