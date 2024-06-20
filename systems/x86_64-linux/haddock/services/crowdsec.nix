{ config, inputs, pkgs, ... }:

{
    nixpkgs.overlays = [ inputs.crowdsec.overlays.default ];

    services = {
        crowdsec = {
            enable = true;
            allowLocalJournalAccess = true;
            enrollKeyFile = config.sops.secrets."haddock/crowdsec/enrollment_key".path;
            settings = {
                api.server.listen_uri = "127.0.0.1:8090";
                crowdsec_service.acquisition_path = (pkgs.formats.yaml {}).generate "acquisitions.yaml" {
                    source = "journalctl";
                    journalctl_filter = ["_SYSTEMD_UNIT=sshd.service"];
                    labels.type = "syslog";
                }; 
            };
        };
        crowdsec-firewall-bouncer = {
            enable = true;
            settings = {
                api_url = "http://localhost:8090";
                api_key = "\${LOCAL_API_KEY}";
            };
        };
    };

    systemd.services = {
        crowdsec.serviceConfig = {
            ExecStartPre = let
                # Registers the firewall bouncer with the security engine, using the local API key
                registerFirewallBouncer = pkgs.writeScriptBin "register-bouncer" ''
                    #!${pkgs.runtimeShell}
                    set -eu
                    set -o pipefail

                    if ! cscli bouncers list | grep -q "firewall"; then
                        cscli bouncers add "firewall" --key "$(cat ${config.sops.secrets."haddock/crowdsec/local_api_key".path})"
                    fi
                '';
            in [
                "${registerFirewallBouncer}/bin/register-bouncer"
            ];
        };
        crowdsec-firewall-bouncer.serviceConfig = {
            EnvironmentFile = config.sops.templates.crowdsec-firewall-bouncer-secrets.path;
        };
    };

    sops = {
        templates = {
            crowdsec-firewall-bouncer-secrets.content = ''
                LOCAL_API_KEY=${config.sops.placeholder."haddock/crowdsec/local_api_key"}
            '';
        };
        secrets = {
            "haddock/crowdsec/enrollment_key".owner = "crowdsec";
            "haddock/crowdsec/local_api_key".owner = "crowdsec";
        };
    };
}
