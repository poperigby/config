{ ... }:

{
    services.postgresql = {
        enable = true;
        ensureDatabases = [
            "authelia"
        ];
        ensureUsers = [
            {
                name = "authelia-haddock";
                ensurePermissions = {
                    "DATABASE authelia" = "ALL PRIVILEGES";
                };
            }
        ];
    };

    # Automatically run a database dump daily, to be backed up by Restic
    services.postgresqlBackup = {
        enable = true;
        backupAll = true;
        compression = "none";
        # TODO: Start before Restic backup
        # startAt = "";
    };
}
