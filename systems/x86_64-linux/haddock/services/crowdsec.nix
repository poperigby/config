{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  services =
    let
      api_uri = "127.0.0.1:8090";
    in
    {
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
          {
            labels.type = "caddy";
            filenames = [ "/var/log/caddy-crowdsec/*.log" ];
          }
          {
            labels.type = "immich";
            source = "journalctl";
            journalctl_filter = [ "_SYSTEMD_UNIT=immich-server.service" ];
          }
          {
            labels.type = "syslog";
            source = "journalctl";
            journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
          }
        ];
        settings.api.server.listen_uri = api_uri;
      };
      crowdsec-firewall-bouncer = {
        enable = true;
        settings = {
          api_key = "\${API_KEY}";
          api_url = "http://${api_uri}";
        };
      };
    };

  systemd.services = {
    crowdsec.serviceConfig.ExecStartPre =
      let
        inherit (lib) getExe;
        inherit (pkgs) writeShellScriptBin;
      in
      [
        # Install configurations from CrowdSec Hub
        (getExe (
          writeShellScriptBin "install-configurations" ''
            set -euo pipefail

            # Define collections to install: core system, app logs, etc.
            collections=(
                LePresidente/authelia            # Authelia brute force detection
                crowdsecurity/auditd             # Post-exploit auditd monitoring
                crowdsecurity/caddy              # Caddy brute force detection
                crowdsecurity/linux              # Core Linux support (includes SSH)
                gauth-fr/immich                  # Immich brute force detection
            )

            # Parsers for special cases
            parsers=(
                crowdsecurity/sshd-success-logs  # Detect successful SSH logins
                crowdsecurity/whitelists         # Prevent banning self (e.g., private IPs)
            )

            # Postoverflow processors (refine or suppress alerts)
            postoverflows=(
                crowdsecurity/auditd-nix-wrappers-whitelist-process  # Ignore benign Nix wrapper execs
            )

            # Install a set of items of a given type (collection, parser, postoverflow)
            install_all() {
                local type=$1
                shift
                local items=($@)

                for id in "''${items[@]}"; do
                    local name="''${id##*/}"  # Extract name after last slash
                    if ! cscli "$type" list | grep -q "$name"; then
                        cscli "$type" install "$id"
                    fi
                done
            }

            install_all collections "''${collections[@]}"
            install_all parsers "''${parsers[@]}"
            install_all postoverflows "''${postoverflows[@]}"
          ''
        ))
        # Registers the firewall bouncer with the security engine, using the local API key
        (getExe (
          writeShellScriptBin "register-bouncer" ''
            set -euo pipefail

            if ! cscli bouncers list | grep -q "firewall"; then
                cscli bouncers add "firewall" --key "$(cat ${
                  config.sops.secrets."haddock/crowdsec/api_keys/firewall_bouncer".path
                })"
            fi
          ''
        ))
      ];
    crowdsec-firewall-bouncer.serviceConfig.EnvironmentFile =
      config.sops.templates.crowdsec-firewall-bouncer-secrets.path;
  };

  # Give CrowdSec access to /var/log/audit
  users.users.crowdsec.extraGroups = [ "audit" ];

  nixpkgs.overlays = [ inputs.crowdsec.overlays.default ];

  sops = {
    templates.crowdsec-firewall-bouncer-secrets.content = # bash
      ''
        API_KEY=${config.sops.placeholder."haddock/crowdsec/api_keys/firewall_bouncer"}
      '';
    secrets = {
      "haddock/crowdsec/enrollment_key".owner = "crowdsec";
      "haddock/crowdsec/api_keys/firewall_bouncer".owner = "crowdsec";
    };
  };
}
