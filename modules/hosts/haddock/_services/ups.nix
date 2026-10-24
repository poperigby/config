{
    config,
    lib,
    pkgs,
    ...
}:

let
    cfg = config.power.ups;
    upsSystem = cfg.upsmon.monitor.cyberpower.system;

    # upsmon passes the message as the first argument and the event in $NOTIFYTYPE
    notifyEmail = pkgs.writeShellApplication {
        name = "ups-notify-email";
        text = ''
            message=$1

            {
                printf 'To: root\n'
                printf 'From: UPS monitor <haddock@mailbox.org>\n'
                printf 'Subject: UPS %s: %s\n' "''${NOTIFYTYPE:-EVENT}" "$message"
                printf 'Content-Type: text/plain; charset=UTF-8\n'
                printf '\n'
                printf '%s\n' "$message"
            } | /run/wrappers/bin/sendmail -t
        '';
    };

    # Restart the NUT server and driver when the UPS status can't be read, which
    # covers both a driver that lost the USB device and an unresponsive upsd
    watchdog = pkgs.writeShellApplication {
        name = "ups-watchdog";
        runtimeInputs = [
            cfg.package
            pkgs.coreutils
            pkgs.systemd
        ];
        text = ''
            if ! output=$(timeout 30 upsc '${upsSystem}' ups.status 2>&1); then
                echo "Unable to read the UPS status ($output), restarting upsd and the UPS driver" >&2
                systemctl restart upsd.service upsdrv.service
            fi
        '';
    };
in
{
    power.ups = {
        enable = true;
        mode = "netserver";
        ups.cyberpower = {
            driver = "usbhid-ups";
            port = "auto";
            description = "CyberPower BRG1350AVRLCD";
            directives = [
                "vendorid = 0764"
                "productid = 0501"
            ];
        };
        upsd.listen = [ { address = "0.0.0.0"; } ];
        users = {
            haddock = {
                passwordFile = config.sops.secrets."haddock/ups/primary_password".path;
                upsmon = "primary";
            };
            snowy = {
                passwordFile = config.sops.secrets."common/ups/password".path;
                upsmon = "secondary";
            };
        };
        upsmon = {
            monitor.cyberpower = {
                system = "cyberpower@localhost";
                user = "haddock";
                type = "primary";
            };
            settings = {
                NOTIFYCMD = lib.getExe notifyEmail;
                NOTIFYFLAG = [
                    [
                        "COMMBAD"
                        "SYSLOG+WALL+EXEC"
                    ]
                    [
                        "COMMOK"
                        "SYSLOG+WALL+EXEC"
                    ]
                    [
                        "NOCOMM"
                        "SYSLOG+WALL+EXEC"
                    ]
                ];
                # Repeat the lost communication alert every 6 hours
                NOCOMMWARNTIME = 21600;
            };
        };
    };

    systemd = {
        services.ups-watchdog = {
            description = "Restart NUT when the UPS status can't be read";
            after = [
                "upsd.service"
                "upsdrv.service"
            ];
            serviceConfig = {
                Type = "oneshot";
                ExecStart = lib.getExe watchdog;
            };
        };
        timers.ups-watchdog = {
            description = "Periodically check that NUT can read the UPS status";
            wantedBy = [ "timers.target" ];
            timerConfig = {
                OnBootSec = "5m";
                OnUnitActiveSec = "1m";
            };
        };
    };

    networking.firewall.interfaces.enp10s0.allowedTCPPorts = [ 3493 ];

    sops.secrets = {
        "haddock/ups/primary_password" = {
            restartUnits = [
                "upsd.service"
                "upsmon.service"
            ];
        };
        "common/ups/password" = {
            restartUnits = [ "upsd.service" ];
        };
    };
}
