{ config, inputs, lib, pkgs, ... }:

{
    nixpkgs.overlays = [ inputs.crowdsec.overlays.default ];

    services = {
        crowdsec = {
            enable = true;
            allowLocalJournalAccess = true;
            enrollKeyFile = config.sops.secrets."haddock/crowdsec/enrollment_key".path;
            acquisitions = [
               {
                   labels.type = "authelia";
                   source = "journalctl";
                   journalctl_filter = [ "_SYSTEMD_UNIT=authelia-haddock.service" ];
               }
               {
                   labels.type = "auditd";
                   filenames = [ "/var/log/audit/*.log" ];
               }
            ];
            settings = {
                api.server.listen_uri = "127.0.0.1:8090";
            };
        };
        crowdsec-firewall-bouncer = {
            enable = true;
            settings = {
                api_key = "\${API_KEY}";
                api_url = "http://localhost:8090";
            };
        };
    };

    systemd.services = {
        crowdsec.serviceConfig = {
            ExecStartPre = let
                # Registers the firewall bouncer with the security engine, using the local API key
                registerFirewallBouncer = pkgs.writeShellScriptBin "register-bouncer" ''
                    set -euo pipefail

                    if ! cscli bouncers list | grep -q "firewall"; then
                        cscli bouncers add "firewall" --key "$(cat ${config.sops.secrets."haddock/crowdsec/api_keys/firewall_bouncer".path})"
                    fi
                '';
                # Install configurations from CrowdSec Hub
                installConfigurations = pkgs.writeShellScriptBin "install-configurations" ''
                    set -euo pipefail

                    ## Collections
                    # Core Linux support
                    if ! cscli collections list | grep -q "linux"; then
                        cscli collections install crowdsecurity/linux
                    fi

                    # Parse Authelia log and detect brute forcing attempts
                    if ! cscli collections list | grep -q "authelia"; then
                        cscli collections install LePresidente/authelia
                    fi

                    # Parse auditd logs and detect post exploit behavior
                    if ! cscli collections list | grep -q "auditd"; then
                        cscli collections install crowdsecurity/auditd
                    fi

                    ## Parsers
                    # Whitelists private IPs, so I don't accidentally ban myself 😬
                    if ! cscli parsers list | grep -q "whitelists"; then
                        cscli parsers install crowdsecurity/whitelists
                    fi
                '';
            in [
                "${registerFirewallBouncer}/bin/register-bouncer"
                "${installConfigurations}/bin/install-configurations"
            ];
        };
        crowdsec-firewall-bouncer.serviceConfig.EnvironmentFile = config.sops.templates.crowdsec-firewall-bouncer-secrets.path;
    };

    # Give CrowdSec access to /var/log/audit
    users.users.crowdsec.extraGroups = [ "audit" ];

    sops = {
        templates = {
            crowdsec-firewall-bouncer-secrets.content = ''
                API_KEY=${config.sops.placeholder."haddock/crowdsec/api_keys/firewall_bouncer"}
            '';
        };
        secrets = {
            "haddock/crowdsec/enrollment_key".owner = "crowdsec";
            "haddock/crowdsec/api_keys/firewall_bouncer".owner = "crowdsec";
        };
    };
}
