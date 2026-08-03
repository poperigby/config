{
    inputs,
    pkgs,
    ...
}:

{
    services = {
        crowdsec = {
            enable = true;
            # Keep the package and rewritten module from the same PR revision;
            # the setup service relies on notification plugins added by that
            # package derivation.
            package = inputs.crowdsec.legacyPackages.${pkgs.stdenv.hostPlatform.system}.crowdsec;
            autoUpdateService = true;
            # Give CrowdSec access to audit logs and systemd journal sources.
            extraGroups = [
                "audit"
                "caddy"
                "systemd-journal"
            ];
            settings = {
                acquisitions = [
                    {
                        labels.type = "authelia";
                        source = "journalctl";
                        journalctl_filter = [
                            "_SYSTEMD_UNIT=authelia-haddock.service"
                            # Pass only Authelia's JSON message to its parser.
                            "-o"
                            "cat"
                        ];
                    }
                    {
                        labels.type = "auditd";
                        filenames = [ "/var/log/audit/*.log" ];
                    }
                    {
                        labels.type = "caddy";
                        filenames = [ "/var/log/caddy/crowdsec.log" ];
                        poll_without_inotify = true;
                    }
                    {
                        labels.type = "syslog";
                        source = "journalctl";
                        journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
                    }
                ];
                parsers.s02Enrich = [
                    {
                        name = "local/auditd-nix-store-whitelist-process";
                        description = "Whitelist executables in the immutable Nix store";
                        filter = "evt.Meta.log_type == 'execve'";
                        whitelist = {
                            reason = "Executable is in the Nix store";
                            expression = [
                                "evt.Meta.exe startsWith '/nix/store/'"
                            ];
                        };
                    }
                ];
                scenarios = [
                    {
                        type = "leaky";
                        name = "local/lldap-bf";
                        description = "Detect brute-force attempts against the LLDAP web login";
                        filter = ''
                            evt.Meta.log_type == 'http_access-log' &&
                            evt.Meta.target_fqdn == 'users.haddock.cc' &&
                            evt.Meta.http_path == '/auth/opaque/login/finish' &&
                            evt.Meta.http_status == '401'
                        '';
                        groupby = "evt.Meta.source_ip";
                        leakspeed = "1m";
                        capacity = 5;
                        blackhole = "5m";
                        reprocess = true;
                        labels = {
                            service = "lldap";
                            behavior = "generic:bruteforce";
                            classification = [ "attack.T1110" ];
                            label = "LLDAP brute force";
                            spoofable = 0;
                            confidence = 3;
                            remediation = true;
                        };
                    }
                ];
            };
            hub = {
                collections = [
                    "LePresidente/authelia" # Authelia brute force detection
                    "crowdsecurity/auditd" # Post-exploit auditd monitoring
                    "crowdsecurity/caddy" # Caddy brute force detection
                    "crowdsecurity/linux" # Core Linux support (includes SSH)
                ];
                parsers = [
                    "crowdsecurity/sshd-success-logs" # Detect successful SSH logins
                    "crowdsecurity/whitelists" # Prevent banning self (e.g., private IPs)
                ];
                postoverflows = [
                    "crowdsecurity/auditd-nix-wrappers-whitelist-process" # Ignore benign Nix wrapper execs
                ];
            };
        };
        crowdsec-firewall-bouncer.enable = true;
    };
}
