{
    config,
    pkgs,
    ...
}:

{
    services.alloy = {
        enable = true;
        environmentFile = config.sops.templates.alloy-loki-environment.path;
    };

    environment.etc."alloy/config.alloy".text = # hcl
        ''
            loki.write "grafana_cloud" {
              endpoint {
                url = "https://logs-prod-021.grafana.net/loki/api/v1/push"

                basic_auth {
                  username = "1706585"
                  password = sys.env("GRAFANA_CLOUD_API_KEY")
                }
              }
            }

            // Preserve useful, low-cardinality journal fields as Loki labels.
            loki.relabel "journal" {
              forward_to = []

              rule {
                source_labels = ["__journal__systemd_unit"]
                target_label  = "unit"
              }

              rule {
                source_labels = ["__journal_syslog_identifier"]
                target_label  = "syslog_identifier"
              }

              rule {
                source_labels = ["__journal_priority_keyword"]
                target_label  = "level"
              }
            }

            loki.source.journal "system" {
              // Avoid uploading a large journal backlog on first activation.
              max_age       = "15m"
              labels        = {
                host = "haddock",
                job  = "systemd-journal",
              }
              relabel_rules = loki.relabel.journal.rules
              forward_to    = [loki.write.grafana_cloud.receiver]
            }

            // These security-relevant logs are files rather than journal streams.
            loki.source.file "security" {
              targets = [
                {
                  __path__ = "/var/log/audit/audit.log",
                  host     = "haddock",
                  job      = "auditd",
                },
                {
                  __path__ = "/var/log/caddy/crowdsec.log",
                  host     = "haddock",
                  job      = "caddy",
                },
              ]
              forward_to             = [loki.write.grafana_cloud.receiver]
              tail_from_end           = true
              on_positions_file_error = "restart_from_end"

              file_match {
                enabled     = true
                sync_period = "10s"
              }
            }
        '';

    # Alloy is already given journal access by the NixOS module. Grant only
    # the additional groups needed to read the two explicit log files above.
    systemd.services.alloy.serviceConfig = {
        SupplementaryGroups = [
            "audit"
            "caddy"
        ];
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
    };

    # Emit a predictable signal so Grafana can distinguish a quiet host from a
    # broken or disabled off-site logging pipeline.
    systemd.services.offsite-log-heartbeat = {
        description = "Emit the off-site logging heartbeat";
        path = [ pkgs.util-linux ];
        script = ''
            logger -t offsite-log-heartbeat -- "Haddock off-site logging heartbeat"
        '';
        serviceConfig = {
            Type = "oneshot";
            DynamicUser = true;
            NoNewPrivileges = true;
        };
    };

    systemd.timers.offsite-log-heartbeat = {
        description = "Periodically verify the off-site logging pipeline";
        wantedBy = [ "timers.target" ];
        timerConfig = {
            OnBootSec = "1m";
            OnUnitActiveSec = "1m";
            AccuracySec = "10s";
        };
    };

    sops = {
        secrets."haddock/grafana/loki/token" = { };
        templates.alloy-loki-environment = {
            content = ''
                GRAFANA_CLOUD_API_KEY=${config.sops.placeholder."haddock/grafana/loki/token"}
            '';
            restartUnits = [ "alloy.service" ];
        };
    };
}
