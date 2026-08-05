{
    config,
    lib,
    pkgs,
    ...
}:

let
    quarantineDir = "/var/lib/clamav/quarantine";

    notifyVirus = pkgs.writeShellApplication {
        name = "clamav-notify-virus";
        text = ''
            virus_name="''${CLAM_VIRUSEVENT_VIRUSNAME:-unknown}"
            filename="''${CLAM_VIRUSEVENT_FILENAME:-unknown}"

            {
                printf 'To: root\n'
                printf 'From: ClamAV <haddock@mailbox.org>\n'
                printf 'Subject: Malware Detected\n'
                printf 'Content-Type: text/plain; charset=UTF-8\n'
                printf '\n'
                printf 'Signature: %s\n' "$virus_name"
                printf 'File: %s\n' "$filename"
            } | /run/wrappers/bin/sendmail -t
        '';
    };

in

{
    services.clamav = {
        daemon = {
            enable = true;
            settings = {
                VirusEvent = lib.getExe notifyVirus;
                # Quarantined files are already known detections. Do not alert
                # on them again during the general /var/lib scan.
                ExcludePath = "^${quarantineDir}(/|$)";
            };
        };
        scanner = {
            enable = true;
            scanDirectories = [
                "/mnt/media/data/torrents"
            ];
        };

        ## Signature updaters
        # Third party
        fangfrisch.enable = true;
        # Official
        updater.enable = true;
    };

    systemd.tmpfiles.rules = [
        # Keep detected files root-only after ClamAV moves them to quarantine.
        "d ${quarantineDir} 0700 root root -"
    ];

    # The NixOS module does not expose clamdscan's quarantine flags, so extend
    # its existing daily scanner rather than creating a second scan job.
    systemd.services.clamdscan = {
        # Let an in-progress scan finish instead of blocking activation while
        # systemd stops and restarts this long-running oneshot service.
        restartIfChanged = false;
        # Require every filesystem used by the scan and quarantine pipeline so
        # unavailable mounts fail the job instead of exposing bare mountpoints.
        unitConfig.RequiresMountsFor = config.services.clamav.scanner.scanDirectories ++ [
            quarantineDir
        ];
        serviceConfig.ExecStart = lib.mkForce ''
            ${lib.getExe' pkgs.clamav "clamdscan"} \
                --multiscan \
                --fdpass \
                --infected \
                --allmatch \
                --move=${quarantineDir} \
                ${lib.escapeShellArgs config.services.clamav.scanner.scanDirectories}
        '';
    };
}
