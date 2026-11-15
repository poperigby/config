{ config, pkgs, ... }:

let
    user = "ledger-bot";
    dataDir = "/var/lib/ledger-bot";

    # Local socket connections use trust authentication, so the URL holds no secret.
    databaseUrl = pkgs.writeText "ledger-bot-database-url" "postgres:///${user}?host=/run/postgresql&user=${user}";

    configFile = (pkgs.formats.toml { }).generate "ledger-bot-config.toml" {
        data_dir = dataDir;
        matrix = {
            homeserver_url = "https://matrix.haddock.cc";
            user_id = "@ledger-bot:haddock.cc";
            display_name = "LedgerBot";
            avatar = ./ledger.jpg;
            # Only these users can invite the bot. Empty allows any joined room.
            allowed_inviter_mxids = [ "@poperigby:haddock.cc" ];
            allowed_room_ids = [ ];
            # Continuwuity delegates authentication to OIDC, which disables password login.
            # The token comes from `!admin users issue-token`, which also created this device.
            device_id = "02UxK6zh2z";
            access_token.file = config.sops.secrets."haddock/ledger_bot/matrix_access_token".path;
            store_passphrase.file = config.sops.secrets."haddock/ledger_bot/matrix_store_passphrase".path;
        };
        postgres = {
            max_connections = 5;
            database_url.file = databaseUrl;
        };
    };
in
{
    services = {
        ledger-bot = {
            enable = true;
            inherit configFile dataDir user;
            group = user;
        };
        postgresql = {
            ensureDatabases = [ user ];
            ensureUsers = [
                {
                    name = user;
                    ensureDBOwnership = true;
                }
            ];
        };
    };

    systemd.services.ledger-bot = {
        requires = [ "postgresql.service" ];
        after = [ "continuwuity.service" ];
    };

    sops.secrets = {
        "haddock/ledger_bot/matrix_access_token" = {
            owner = user;
            restartUnits = [ "ledger-bot.service" ];
        };
        "haddock/ledger_bot/matrix_store_passphrase" = {
            owner = user;
            restartUnits = [ "ledger-bot.service" ];
        };
    };
}
