{
    config,
    lib,
    pkgs,
    ...
}:

let
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
                ExcludePath = "^/var/lib/clamav/quarantine(/|$)";
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
        "d /var/lib/clamav/quarantine 0700 root root -"
    ];

    # The NixOS module does not expose clamdscan's quarantine flags, so extend
    # its existing daily scanner rather than creating a second scan job.
    systemd.services.clamdscan.serviceConfig.ExecStart = lib.mkForce ''
        ${lib.getExe' pkgs.clamav "clamdscan"} \
            --multiscan \
            --fdpass \
            --infected \
            --allmatch \
            --move=/var/lib/clamav/quarantine \
            ${lib.escapeShellArgs config.services.clamav.scanner.scanDirectories}
    '';
}
