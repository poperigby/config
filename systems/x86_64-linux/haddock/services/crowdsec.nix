{ ... }:

{
    services = {
        crowdsec = {
            enable = true;
            autoUpdateService = true;
            localConfig = {
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
                        poll_without_inotify = true;
                    }
                    {
                        labels.type = "immich";
                        source = "journalctl";
                        journalctl_filter = [ "_SYSTEMD_UNIT=immich-server.service" ];
                    }
                    {
                        labels.type = "jellyfin";
                        source = "journalctl";
                        journalctl_filter = [ "_SYSTEMD_UNIT=jellyfin.service" ];
                    }
                    {
                        labels.type = "syslog";
                        source = "journalctl";
                        journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
                    }
                ];
            };
            hub = {
                collections = [
                    "LePresidente/authelia" # Authelia brute force detection
                    "LePresidente/jellyfin" # Jellyfin parser and bruteforce detection
                    "crowdsecurity/auditd" # Post-exploit auditd monitoring
                    "crowdsecurity/caddy" # Caddy brute force detection
                    "crowdsecurity/linux" # Core Linux support (includes SSH)
                    "gauth-fr/immich" # Immich brute force detection
                ];
                parsers = [
                    "crowdsecurity/sshd-success-logs" # Detect successful SSH logins
                    "crowdsecurity/whitelists" # Prevent banning self (e.g., private IPs)
                ];
                postOverflows = [
                    "crowdsecurity/auditd-nix-wrappers-whitelist-process" # Ignore benign Nix wrapper execs
                ];
            };
        };
        crowdsec-firewall-bouncer.enable = true;
    };

    # Give CrowdSec access to /var/log/audit
    users.users.crowdsec.extraGroups = [ "audit" ];

    sops = {
        secrets = {
            "haddock/crowdsec/enrollment_key".owner = "crowdsec";
        };
    };
}
