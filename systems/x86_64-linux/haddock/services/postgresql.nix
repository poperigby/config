{ ... }:

{
    services = {
        postgresql = {
            enable = true;
            ensureDatabases = [
                "authelia-haddock"
                "lldap"
                "mealie"
                "nextcloud"
            ];
            ensureUsers = [
                {
                    name = "root";
                    ensureClauses.superuser = true;
                }
                {
                    name = "authelia-haddock";
                    ensureDBOwnership = true;
                }
                {
                    name = "lldap";
                    ensureDBOwnership = true;
                }
                {
                    name = "mealie";
                    ensureDBOwnership = true;
                }
                {
                    name = "nextcloud";
                    ensureDBOwnership = true;
                }
            ];
        };

        # Automatically run a database dump daily, to be backed up by Restic
        postgresqlBackup = {
            enable = true;
            backupAll = true;
            # Restic already compresses backups, so no need to do it here too
            compression = "none";
            startAt = "*-*-* 00:00:00";
        };
    };

    # Run the database dump before performing a Restic backup
    systemd.services.postgresqlBackup.before = [ "restic-backups-borgbase.service" ];
}
