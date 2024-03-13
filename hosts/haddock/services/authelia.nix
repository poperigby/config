{ config, ... }:

{
    sops.secrets = {
        "haddock/authelia/jwt_secret" = {};
        "haddock/authelia/storage_encryption_key" = {};
    };

    services.authelia.instances.haddock = {
        enable = true;
        secrets = {
            jwtSecretFile = config.sops.secrets."haddock/authelia/jwt_secret".path;
            storageEncryptionKeyFile = config.sops.secrets."haddock/authelia/storage_encryption_key".path;
        };
    };
}
