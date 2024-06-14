{ config, inputs, ... }:

let
    cfg = config.services.gatus;
in
{
    imports = [ "${inputs.gatus}/nixos/modules/services/monitoring/gatus.nix" ];

    services = {
        gatus = {
            enable = true;
            settings = {
                endpoints = [
                    {
                        name = "Nextcloud";
                        url = "https://cloud.haddock.cc";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                ];
            };
        };
        caddy.virtualHosts."status.haddock.cc".extraConfig = ''
            import auth
            reverse_proxy :${builtins.toString cfg.settings.web.port}
        '';
    };
}
