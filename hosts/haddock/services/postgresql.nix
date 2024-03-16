{ ... }:

{
    services.postgresql = {
        enable = true;
        ensureDatabases = [
            "authelia-haddock"
        ];
        ensureUsers = [
            {
                name = "authelia-haddock";
                ensureDBOwnership = true;
            }
        ];
    };

    # Automatically run a database dump daily, to be backed up by Restic
    services.postgresqlBackup = {
        enable = true;
        backupAll = true;
        compression = "none";
        startAt = "*-*-* 00:00:00";
    };

    # Run the database dump before performing a Restic backup
    systemd.services.postgresqlBackup.before = [ "restic-backups-borgbase.service" ];
}
