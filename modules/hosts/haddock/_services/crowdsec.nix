{
    config,
    lib,
    pkgs,
    ...
}:

{
    services = {
        crowdsec = {
            enable = true;
            autoUpdateService = true;
            # Give CrowdSec access to audit logs and systemd journal sources.
            extraGroups = [
                "audit"
                "caddy"
                "systemd-journal"
            ];
            settings = {
                # Persist CAPI credentials in CrowdSec's state directory and
                # enroll this engine using a token kept outside the Nix store.
                config.api.server.online_client.credentials_path =
                    "/var/lib/crowdsec/data/online_api_credentials.yaml";
                config.config_paths.simulation_path = "/etc/crowdsec/simulation.yaml";
                console.enrollKeyFile = config.sops.secrets."haddock/crowdsec/enroll_key".path;
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
                    {
                        name = "local/auditd-nixos-docker-runc-whitelist-process";
                        description = "Whitelist NixOS Docker runc init processes";
                        filter = "evt.Meta.log_type == 'execve'";
                        whitelist = {
                            reason = "Process is the container-side init stage of NixOS Docker runc";
                            expression = [
                                "evt.Meta.exe == '/.runc-wrapped' && evt.Meta.parent_progname matches '^/nix/store/[a-z0-9]{32}-docker-runc-[^/]+/bin/[.]runc-wrapped$'"
                            ];
                        };
                    }
                ];
                notifications = [
                    {
                        type = "email";
                        name = "auditd_email";
                        log_level = "info";
                        # Nearby alerts are batched to avoid an email storm during one event.
                        group_wait = "30s";
                        group_threshold = 10;
                        max_retry = 3;
                        timeout = "20s";
                        sender_name = "CrowdSec";
                        sender_email = "haddock@mailbox.org";
                        email_subject = "Auditd Detected Suspicious Activity";
                        receiver_emails = [ "root@localhost" ];
                        smtp_host = "127.0.0.1";
                        smtp_port = 25;
                        encryption_type = "none";
                        auth_type = "none";
                        # The email plugin renders this field as HTML. Each row
                        # represents one alert and uses its first event for
                        # context. The Events column shows the full event count.
                        format = # html
                            ''
                                <html>
                                <body style="font-family: sans-serif;">
                                  <table style="width: 100%; border-collapse: collapse;">
                                    <thead>
                                      <tr>
                                        <th style="text-align: left; padding: 6px; border-bottom: 1px solid #ccc;">Scenario</th>
                                        <th style="text-align: left; padding: 6px; border-bottom: 1px solid #ccc;">Executable</th>
                                        <th style="text-align: left; padding: 6px; border-bottom: 1px solid #ccc;">User</th>
                                        <th style="text-align: left; padding: 6px; border-bottom: 1px solid #ccc;">PID</th>
                                        <th style="text-align: right; padding: 6px; border-bottom: 1px solid #ccc;">Events</th>
                                        <th style="text-align: left; padding: 6px; border-bottom: 1px solid #ccc;">Time</th>
                                      </tr>
                                </thead>
                                <tbody>
                                  {{/* Sprig cannot sort alert objects directly. Invert and zero-pad the event count so alphabetically sorted keys produce descending counts. The sequence suffix keeps equal-sized alerts unique. */}}
                                  {{ $alerts := dict }}
                                  {{ $sequence := 0 }}
                                  {{ range . }}
                                  {{ $_ := set $alerts (printf "%09d-%09d" (sub 999999999 (len .Events)) $sequence) . }}
                                  {{ $sequence = add1 $sequence }}
                                  {{ end }}
                                  {{ range keys $alerts | sortAlpha }}
                                  {{ $alert := get $alerts . }}
                                  {{ $event := index $alert.Events 0 }}
                                  <tr>
                                    <td style="padding: 6px; border-bottom: 1px solid #ccc;">{{ $alert.Scenario | HTMLEscape }}</td>
                                    <td style="padding: 6px; border-bottom: 1px solid #ccc;"><code>{{ $event.GetMeta "exe" | HTMLEscape }}</code></td>
                                    <td style="padding: 6px; border-bottom: 1px solid #ccc;">{{ $event.GetMeta "str_UID" | HTMLEscape }}</td>
                                    <td style="padding: 6px; border-bottom: 1px solid #ccc;">{{ $event.GetMeta "pid" | HTMLEscape }}</td>
                                    <td style="text-align: right; padding: 6px; border-bottom: 1px solid #ccc;">{{ len $alert.Events }}</td>
                                    <td style="padding: 6px; border-bottom: 1px solid #ccc;">{{ $event.Timestamp }}</td>
                                  </tr>
                                      {{ end }}
                                    </tbody>
                                  </table>
                                </body>
                                </html>
                            '';
                    }
                ];
                # Email every auditd scenario, including local replacements for
                # upstream rules that assume FHS executable paths.
                profiles = [
                    {
                        name = "auditd_email_notification";
                        filters = [
                            "Alert.GetScenario() startsWith 'crowdsecurity/auditd-' || Alert.GetScenario() startsWith 'local/auditd-'"
                        ];
                        decisions = [ ];
                        notifications = [ "auditd_email" ];
                        on_success = "break";
                    }
                    # Keep the module's default remediation profiles: defining
                    # a notification profile replaces the entire default list.
                    {
                        name = "default_ip_remediation";
                        filters = [
                            "Alert.Remediation == true && Alert.GetScope() == 'Ip'"
                        ];
                        decisions = [
                            {
                                type = "ban";
                                duration = "4h";
                            }
                        ];
                        on_success = "break";
                    }
                    {
                        name = "default_range_remediation";
                        filters = [
                            "Alert.Remediation == true && Alert.GetScope() == 'Range'"
                        ];
                        decisions = [
                            {
                                type = "ban";
                                duration = "4h";
                            }
                        ];
                        on_success = "break";
                    }
                ];
                scenarios = [
                    {
                        type = "leaky";
                        name = "local/auditd-postexploit-rm";
                        description = "Detect bursts of rm executions from one parent process";
                        filter = "evt.Meta.log_type == 'execve' && evt.Meta.comm == 'rm'";
                        groupby = "evt.Meta.ppid";
                        leakspeed = "1s";
                        capacity = 5;
                        blackhole = "1m";
                        labels = {
                            service = "linux";
                            behavior = "linux:post-exploitation";
                            classification = [ "attack.T1059.004" ];
                            label = "Post Exploitation command execution";
                            spoofable = 0;
                            confidence = 1;
                            remediation = false;
                        };
                        scope = {
                            type = "pid";
                            expression = "evt.Meta.ppid";
                        };
                    }
                    {
                        type = "leaky";
                        name = "local/auditd-postexploit-pkill";
                        description = "Detect bursts of pkill executions from one parent process";
                        filter = "evt.Meta.log_type == 'execve' && evt.Meta.comm == 'pkill'";
                        groupby = "evt.Meta.ppid";
                        leakspeed = "1s";
                        capacity = 5;
                        blackhole = "1m";
                        labels = {
                            service = "linux";
                            behavior = "linux:post-exploitation";
                            classification = [ "attack.T1059.004" ];
                            label = "Post Exploitation command execution";
                            spoofable = 0;
                            confidence = 2;
                            remediation = false;
                        };
                        scope = {
                            type = "pid";
                            expression = "evt.Meta.ppid";
                        };
                    }
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
        crowdsec-firewall-bouncer = {
            enable = true;
            # Docker-published ports traverse DOCKER-USER instead of INPUT.
            settings = {
                api_url = "http://127.0.0.1:8080";
                iptables_chains = [
                    "INPUT"
                    "DOCKER-USER"
                ];
            };
        };
    };

    # Docker creates DOCKER-USER when its firewall is initialized. Ensure that
    # chain exists before the bouncer installs its rules.
    systemd.services.crowdsec-firewall-bouncer = {
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
    };

    # Activation may restart registration while CrowdSec itself remains up.
    # Wait for setup to create CAPI credentials before invoking cscli.
    systemd.services.crowdsec-firewall-bouncer-register = {
        after = [ "crowdsec-setup.service" ];
        requires = [ "crowdsec-setup.service" ];
    };

    # The module's privileged pre-start cannot resolve a DynamicUser by name
    # on the first boot. systemd has already assigned the configuration
    # directory its numeric UID, so copy that ownership to its contents.
    systemd.services.crowdsec-setup.serviceConfig = {
        ExecStartPre = lib.mkForce [
            "+${lib.getExe' pkgs.coreutils "chown"} --reference=/etc/crowdsec -R /etc/crowdsec"
            "+${lib.getExe' pkgs.coreutils "chmod"} 750 -R /etc/crowdsec"
        ];
        # Hub updates can be temporarily rejected by the CDN. Retry with
        # enough backoff to avoid turning a transient error into rate limiting.
        Restart = "on-failure";
        RestartSec = "15min";
    };

    sops.secrets."haddock/crowdsec/enroll_key".restartUnits = [
        "crowdsec-setup.service"
    ];

}
