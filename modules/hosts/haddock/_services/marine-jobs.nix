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
    # --quiet when there's nothing new, so an empty run sends no mail. The
    # updated seen list is staged and replaces seen.json only after sendmail
    # succeeds, so posts from an undelivered report stay new for the next run.
    marineJobsReport = pkgs.writeShellApplication {
        name = "marine-jobs-report";
        runtimeInputs = [
            pkgs.coreutils
            pkgs.gnused
            pkgs.local.marine-jobs
        ];
        text = ''
            seen="$STATE_DIRECTORY/seen.json"
            pending="$STATE_DIRECTORY/seen.json.pending"
            rm -f "$pending"

            report=$(marine-jobs --new --quiet --html --seen-out "$pending")
            if [ -z "$report" ]; then
                mv "$pending" "$seen"
                exit 0
            fi

            summary=$(printf '%s\n' "$report" | sed -n 's|.*<title>\(.*\)</title>.*|\1|p' | head -n1)

            # The table rows can exceed SMTP's 998-character line limit, so the
            # body is base64-encoded.
            {
                printf 'To: root\n'
                printf 'From: Marine jobs <haddock@mailbox.org>\n'
                printf 'Subject: %s\n' "''${summary:-New marine job posts}"
                printf 'MIME-Version: 1.0\n'
                printf 'Content-Type: text/html; charset=UTF-8\n'
                printf 'Content-Transfer-Encoding: base64\n'
                printf '\n'
                printf '%s\n' "$report" | base64 -w 76
            } | /run/wrappers/bin/sendmail -t

            mv "$pending" "$seen"
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
                # DynamicUser implies NoNewPrivileges, so the setgid sendmail wrapper
                # cannot gain the postdrop group needed to write to the maildrop queue.
                SupplementaryGroups = [ "postdrop" ];
                # ProtectSystem=strict mounts /var read-only, which postdrop writes into.
                ReadWritePaths = [ "/var/lib/postfix/queue/maildrop" ];
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
