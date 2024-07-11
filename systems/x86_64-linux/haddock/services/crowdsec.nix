{ config, inputs, lib, pkgs, ... }:

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
                    journalctl_filter = ["_SYSTEMD_UNIT=authelia-haddock.service"];
                    labels.type = "authelia";
                }; 
            };
        };
        crowdsec-firewall-bouncer = {
            enable = true;
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
                # Install collections for parsing log files and recognizing scenarios
                installCollections = pkgs.writeShellScriptBin "install-collections" ''
                    set -euo pipefail

                    if ! cscli collections list | grep -q "authelia"; then
                        cscli collections install LePresidente/authelia
                    fi
                '';
            in [
                "${registerFirewallBouncer}/bin/register-bouncer"
                "${installCollections}/bin/install-collections"
            ];
        };
        crowdsec-firewall-bouncer.serviceConfig = let
            pkg = config.services.crowdsec-firewall-bouncer.package; 
            configFile = config.sops.templates.crowdsec-firewall-bouncer-config.path;
        in {
            ExecStart = lib.mkForce "${pkg}/bin/cs-firewall-bouncer -c ${configFile}";
            ExecStartPre = lib.mkForce ["${pkg}/bin/cs-firewall-bouncer -t -c ${configFile}"];
        };
    };

    sops = {
        templates = {
            crowdsec-firewall-bouncer-config.content = # bash
            ''
                api_key: ${config.sops.placeholder."haddock/crowdsec/api_keys/firewall_bouncer"}
                api_url: http://localhost:8090
                blacklists_ipv4: crowdsec-blacklists
                blacklists_ipv6: crowdsec6-blacklists
                deny_action: DROP
                ipset_type: nethash
                iptables_chains:
                - INPUT
                log_mode: stdout
                mode: iptables
                update_frequency: 10s
            '';
        };
        secrets = {
            "haddock/crowdsec/enrollment_key".owner = "crowdsec";
            "haddock/crowdsec/api_keys/firewall_bouncer".owner = "crowdsec";
        };
    };
}
