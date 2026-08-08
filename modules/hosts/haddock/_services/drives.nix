{
    lib,
    pkgs,
    ...
}:

# Operational health and maintenance policy for Haddock's drives
let
    btrfsDeviceErrorMonitor = pkgs.writeShellApplication {
        name = "btrfs-device-error-monitor";
        runtimeInputs = with pkgs; [
            btrfs-progs
            coreutils
            gawk
        ];
        text = ''
            state_directory=/var/lib/btrfs-device-error-monitor
            increased=false
            work_directory=$(mktemp -d)
            report="$work_directory/report"
            trap 'rm -rf "$work_directory"' EXIT

            check_filesystem() {
                name=$1
                path=$2
                baseline="$state_directory/$name"
                current="$work_directory/$name"

                for counter in \
                    write_io_errs \
                    read_io_errs \
                    flush_io_errs \
                    corruption_errs \
                    generation_errs
                do
                    value=$(btrfs device stats "$path" | awk -v counter=".$counter" \
                        '$1 ~ counter "$" { total += $2 } END { print total + 0 }')
                    printf '%s %s\n' "$counter" "$value" >> "$current"
                done

                if [ -e "$baseline" ]; then
                    while read -r counter value; do
                        previous=$(awk -v counter="$counter" '$1 == counter { print $2 }' "$baseline")
                        previous=''${previous:-0}
                        if [ "$value" -gt "$previous" ]; then
                            increased=true
                            printf '%s (%s): %s increased from %s to %s\n' \
                                "$name" "$path" "$counter" "$previous" "$value" >> "$report"
                        fi
                    done < "$current"
                fi
            }

            check_filesystem root /
            check_filesystem media /mnt/media

            if "$increased"; then
                {
                    printf 'To: root\n'
                    printf 'From: Btrfs monitor <haddock@mailbox.org>\n'
                    printf 'Subject: Btrfs device errors increased on haddock\n'
                    printf 'Content-Type: text/plain; charset=UTF-8\n'
                    printf '\n'
                    printf 'One or more persistent Btrfs device-error counters increased:\n\n'
                    cat "$report"
                    printf '\nCurrent device statistics:\n\n'
                    btrfs device stats /
                    printf '\n'
                    btrfs device stats /mnt/media
                } | /run/wrappers/bin/sendmail -t
            fi

            mv "$work_directory/root" "$state_directory/root"
            mv "$work_directory/media" "$state_directory/media"
        '';
    };
in
{
    services.btrfs.autoScrub = {
        enable = true;
        fileSystems = [
            "/"
            "/mnt/media"
        ];
    };

    # Stagger the two filesystems so their scrubs do not compete for I/O.
    systemd.timers = {
        "btrfs-scrub--".timerConfig.OnCalendar = lib.mkForce "*-*-01 03:00:00";
        "btrfs-scrub-mnt-media".timerConfig.OnCalendar = lib.mkForce "*-*-15 03:00:00";
        btrfs-device-error-monitor = {
            description = "Monitor Btrfs device-error counters hourly";
            wantedBy = [ "timers.target" ];
            timerConfig = {
                OnBootSec = "10m";
                OnUnitActiveSec = "1h";
                Persistent = true;
            };
        };
    };

    systemd.services = {
        "btrfs-scrub--".unitConfig.OnFailure = "notify-btrfs-scrub-failure@%n.service";
        "btrfs-scrub-mnt-media".unitConfig.OnFailure = "notify-btrfs-scrub-failure@%n.service";

        "notify-btrfs-scrub-failure@" = {
            description = "Email notification for failed Btrfs scrub unit %I";
            serviceConfig = {
                Type = "oneshot";
                ExecStart =
                    lib.getExe (
                        pkgs.writeShellApplication {
                            name = "notify-btrfs-scrub-failure";
                            text = ''
                                unit="$1"

                                {
                                  printf 'To: root\n'
                                  printf 'From: Btrfs <haddock@mailbox.org>\n'
                                  printf 'Subject: Btrfs scrub failed on haddock: %s\n' "$unit"
                                  printf 'Content-Type: text/plain; charset=UTF-8\n'
                                  printf '\n'
                                  ${lib.getExe' pkgs.systemd "journalctl"} --boot --unit "$unit" --lines 100 --no-pager
                                } | /run/wrappers/bin/sendmail -t
                            '';
                        }
                    )
                    + " %I";
            };
        };

        btrfs-device-error-monitor = {
            description = "Alert when Btrfs device-error counters increase";
            serviceConfig = {
                Type = "oneshot";
                ExecStart = lib.getExe btrfsDeviceErrorMonitor;
                StateDirectory = "btrfs-device-error-monitor";
                ProtectSystem = "strict";
                ProtectHome = true;
                PrivateTmp = true;
            };
        };
    };

    services.smartd = {
        # Monitor all SMART attributes, run short tests on weekday mornings,
        # and run the more I/O-intensive extended tests on Saturdays.
        defaults.monitored = "-a -s (S/../../[1-5]/03|L/../../6/04)";
        notifications = {
            mail = {
                enable = true;
                sender = "haddock@mailbox.org";
                recipient = "root";
            };
            wall.enable = false;
        };
    };
}
