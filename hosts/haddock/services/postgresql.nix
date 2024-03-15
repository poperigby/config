{ ... }:

{
    services.postgresql = {
        enable = true;
    };

    services.postgresqlBackup = {
        enable = true;
        backupAll = true;
        compression = "none";
        # TODO: Start before Restic backup
        # startAt = "";
    };
}
