{ config, inputs, pkgs, ... }:

{
    nixpkgs.overlays = [ inputs.crowdsec.overlays.default ];

    services = {
        crowdsec = {
            # enable = true;
            enrollKeyFile = config.sops.secrets."haddock/crowdsec/enrollment_key".path;
            settings = {
                api.server = {
                    listen_uri = "127.0.0.1:8090";
                };
            };
        };
        crowdsec-firewall-bouncer = {
            # enable = true;
            settings = {
                api_url = "http://localhost:8090";
            };
        };
    };

    # systemd.services.crowdsec.serviceConfig = {
    #     ExecStartPre = let
    #         script = pkgs.writeScriptBin "register-bouncer" ''
    #             #!${pkgs.runtimeShell}
    #             set -eu
    #             set -o pipefail
    #
    #             if ! cscli bouncers list | grep -q "firewall"; then
    #                 cscli bouncers add "firewall" --key "$(cat ${config.sops.secrets."haddock/crowdsec/local_api_key".path})"
    #             fi
    #         '';
    #     in ["${script}/bin/register-bouncer"];
    # };
    #
    # sops = {
    #     secrets = {
    #         "haddock/crowdsec/enrollment_key".owner = "crowdsec";
    #         "haddock/crowdsec/local_api_key".owner = "crowdsec";
    #     };
    # };
}
