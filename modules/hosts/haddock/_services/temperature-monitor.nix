{ lib, pkgs, ... }:

let
    warningTemperature = 85;
    recoveryTemperature = 75;
    requiredHotReadings = 4;

    temperatureMonitor = pkgs.writeShellApplication {
        name = "temperature-monitor";
        runtimeInputs = [ pkgs.coreutils ];
        text = ''
            state_directory=/var/lib/temperature-monitor
            hot_readings_file="$state_directory/hot-readings"
            alerted_file="$state_directory/alerted"

            send_temperature_email() {
                subject=$1
                status=$2
                temperature=$3

                {
                    printf 'To: root\n'
                    printf 'From: Temperature monitor <haddock@mailbox.org>\n'
                    printf 'Subject: %s\n' "$subject"
                    printf 'Content-Type: text/plain; charset=UTF-8\n'
                    printf '\n'
                    printf 'CPU temperature on haddock is %s: %s C.\n' "$status" "$temperature"
                    printf 'Warning threshold: %s C; recovery threshold: %s C.\n' \
                        '${toString warningTemperature}' '${toString recoveryTemperature}'
                } | /run/wrappers/bin/sendmail -t
            }

            while true; do
                sensor=
                for hwmon in /sys/class/hwmon/hwmon*; do
                    if read -r name < "$hwmon/name" && [ "$name" = k10temp ]; then
                        sensor=$hwmon/temp1_input
                        break
                    fi
                done

                if [ -z "$sensor" ] || ! read -r millidegrees < "$sensor"; then
                    echo "Unable to read the k10temp Tctl sensor" >&2
                    sleep 30
                    continue
                fi

                temperature=$((millidegrees / 1000))

                if [ "$temperature" -ge '${toString warningTemperature}' ]; then
                    hot_readings=0
                    if [ -r "$hot_readings_file" ]; then
                        read -r hot_readings < "$hot_readings_file" || hot_readings=0
                    fi
                    hot_readings=$((hot_readings + 1))
                    printf '%s\n' "$hot_readings" > "$hot_readings_file"

                    if [ "$hot_readings" -ge '${toString requiredHotReadings}' ] && [ ! -e "$alerted_file" ]; then
                        send_temperature_email \
                            "URGENT: haddock CPU temperature is $temperature C" \
                            dangerously-high "$temperature"
                        touch "$alerted_file"
                    fi
                elif [ "$temperature" -le '${toString recoveryTemperature}' ]; then
                    rm -f "$hot_readings_file"
                    if [ -e "$alerted_file" ]; then
                        send_temperature_email \
                            "RECOVERED: haddock CPU temperature is $temperature C" \
                            back-to-normal "$temperature"
                        rm -f "$alerted_file"
                    fi
                fi

                sleep 30
            done
        '';
    };
in
{
    systemd.services.temperature-monitor = {
        description = "Monitor CPU temperature and send email alerts";
        wantedBy = [ "multi-user.target" ];
        after = [ "postfix.service" ];
        serviceConfig = {
            ExecStart = lib.getExe temperatureMonitor;
            Restart = "always";
            RestartSec = "10s";
            StateDirectory = "temperature-monitor";
            DynamicUser = true;
            # DynamicUser implies NoNewPrivileges, so the setgid sendmail wrapper
            # cannot gain the postdrop group needed to write to the maildrop queue.
            SupplementaryGroups = [ "postdrop" ];
            # ProtectSystem=strict mounts /var read-only, which postdrop writes into.
            ReadWritePaths = [ "/var/lib/postfix/queue/maildrop" ];
            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateTmp = true;
        };
    };
}
