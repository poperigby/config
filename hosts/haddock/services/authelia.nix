{ config, ... }:

{
    sops.secrets = {
        "haddock/authelia/jwt_secret" = {
            owner = "authelia-haddock";
        };
        "haddock/authelia/storage_encryption_key" = {
            owner = "authelia-haddock";
        };
    };

    services.authelia.instances.haddock = {
        enable = true;
        secrets = {
            jwtSecretFile = config.sops.secrets."haddock/authelia/jwt_secret".path;
            storageEncryptionKeyFile = config.sops.secrets."haddock/authelia/storage_encryption_key".path;
        };
        settings = {
            theme = "auto";
            storage = {
                postgres = {
                    address = "tcp://127.0.0.1:5432";
                    database = "authelia";
                    username = "authelia-haddock";
                    password = "";
                };
            };
            # authentication_backend = {
            #
            # };
        };
    };
}
