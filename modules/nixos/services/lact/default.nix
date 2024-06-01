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
        enable = lib.mkEnableOption "Enable LACT for controlling AMD GPUs";
        gpuOverclock = {
            enable = lib.mkEnableOption "Whether to enable GPU overclocking";
            ppfeaturemask = lib.mkOption {
                type = lib.types.str;
                default = "0xfffd7fff";
                example = "0xffffffff";
                description = ''
                    Sets the `amdgpu.ppfeaturemask` kernel option. In particular, it is used here to set the
                    overdrive bit. Default is `0xfffd7fff` as it is less likely to cause flicker issues. Setting
                    it to `0xffffffff` enables all features.
                '';
            };
        };
        configFile = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = lib.mdDoc ''
                Path to a LACT `config.yaml`. Mutually exclusive with the `settings` option.
            '';
        };
        settings = lib.mkOption {
            type = settingsFormat.type;
            default = {
                daemon = {
                    log_level = "info";
                    admin_groups = [ "wheel" "sudo" ];
                    disable_clocks_cleanup = false;
                };
                apply_settings_timer = 5;
                gpus = [];
            };
            description = lib.mdDoc ''
                LACT configuration as an attribute set.
            '';
        };
    };

    config = lib.mkIf cfg.enable (lib.mkMerge [
        {
            assertions = [
                {
                    assertion = (cfg.settings != {}) != (cfg.configFile != null);
                    message = "The `settings` and `configFile` options are mutually exclusive.";
                }
            ];

            environment.etc."lact/config.yaml".source = configFile;

            # Copied from https://github.com/ilya-zlobintsev/LACT/blob/master/res/lactd.service
            systemd.services.lactd = {
                wantedBy = [ "multi-user.target" ];
                unitConfig = {
                    Description = "AMDGPU Control Daemon";
                    After = [ "multi-user.target" ];
                };
                serviceConfig = {
                    ExecStart = "${pkgs.lact}/bin/lact daemon";
                    Nice = -10;
                };
            };
        }
        (lib.mkIf cfg.gpuOverclock.enable {
            # https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/gpu/drm/amd/include/amd_shared.h#n169
            # The overdrive bit
            boot.kernelParams = [ "amdgpu.ppfeaturemask=${cfg.gpuOverclock.ppfeaturemask}" ];
        })
    ]);
}
