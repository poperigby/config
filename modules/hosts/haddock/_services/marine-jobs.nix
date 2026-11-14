{
    config,
    lib,
    pkgs,
    privateInfo,
    ...
}:

let
    # Enable once haddock/marine-jobs/usajobs_api_key is in private-config.
    # Without it, marine-jobs skips the USAJOBS source.
    useUsajobs = false;

    # Emails new marine-biology job posts. marine-jobs prints nothing with
    # --quiet when there's nothing new, so an empty run sends no mail.
    marineJobsReport = pkgs.writeShellApplication {
        name = "marine-jobs-report";
        runtimeInputs = [
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.local.marine-jobs
        ];
        text = ''
            report=$(marine-jobs --new --quiet)
            if [ -z "$report" ]; then
                exit 0
            fi

            summary=$(printf '%s\n' "$report" | grep -m1 'matching posts' || true)

            {
                printf 'To: root\n'
                printf 'From: Marine jobs <haddock@mailbox.org>\n'
                printf 'Subject: %s\n' "''${summary:-New marine job posts}"
                printf 'Content-Type: text/plain; charset=UTF-8\n'
                printf '\n'
                printf '%s\n' "$report"
            } | /run/wrappers/bin/sendmail -t
        '';
    };
in
{
    systemd = {
        services.marine-jobs = {
            description = "Email new marine-biology job posts";
            wants = [ "network-online.target" ];
            after = [
                "network-online.target"
                "postfix.service"
            ];
            serviceConfig = {
                Type = "oneshot";
                ExecStart = lib.getExe marineJobsReport;
                StateDirectory = "marine-jobs";
                DynamicUser = true;
                ProtectSystem = "strict";
                ProtectHome = true;
                PrivateTmp = true;
            }
            // lib.optionalAttrs useUsajobs {
                # Read by systemd before dropping to the dynamic user.
                EnvironmentFile = config.sops.templates.marine-jobs-environment.path;
            };
        };
        timers.marine-jobs = {
            description = "Check for new marine-biology job posts every morning";
            wantedBy = [ "timers.target" ];
            timerConfig = {
                OnCalendar = "*-*-* 08:00:00";
                Persistent = true;
                RandomizedDelaySec = "10min";
            };
        };
    };

    sops = lib.mkIf useUsajobs {
        templates.marine-jobs-environment.content = ''
            USAJOBS_API_KEY=${config.sops.placeholder."haddock/marine-jobs/usajobs_api_key"}
            USAJOBS_EMAIL=${privateInfo.cassidy.email}
        '';
        secrets."haddock/marine-jobs/usajobs_api_key" = { };
    };
}
