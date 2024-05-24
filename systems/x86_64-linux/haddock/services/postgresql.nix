{ ... }:

{
    services.postgresql = {
        enable = true;
        ensureDatabases = [
            "authelia-haddock"
            "lldap"
        ];
        ensureUsers = [
            {
                name = "authelia-haddock";
                ensureDBOwnership = true;
            }
            {
                name = "lldap";
                ensureDBOwnership = true;
            }
        ];
    };

    # Automatically run a database dump daily, to be backed up by Restic
    services.postgresqlBackup = {
        enable = true;
        backupAll = true;
        # Restic already compresses backups, so this is redundant
        compression = "none";
        startAt = "*-*-* 00:00:00";
    };

    # Run the database dump before performing a Restic backup
    systemd.services.postgresqlBackup.before = [ "restic-backups-borgbase.service" ];
}
