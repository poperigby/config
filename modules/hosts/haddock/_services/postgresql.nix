{ lib, pkgs, ... }:

{
    services.postgresql = {
        enable = true;
        package = pkgs.postgresql_18;
        ensureDatabases = [
            "authelia-haddock"
            "lldap"
            "mealie"
            "vikunja"
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
                name = "vikunja";
                ensureDBOwnership = true;
            }
        ];
        # TODO: Required for Vikunja, but can I tighten it up?
        authentication = lib.mkForce ''
            # TYPE  DATABASE        USER            ADDRESS                 METHOD
            local   all             all                                     trust
            host    all             all             127.0.0.1/32            trust
            host    all             all             ::1/128                 trust
        '';
    };
}
