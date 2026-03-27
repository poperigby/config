{ den, ... }:
{
    den.aspects.cassidy = {
        includes = [
            den.provides.primary-user
        ];

        # nixos = {
        #     hashedPasswordFile = config.sops.secrets."common/users/cassidy/password".path;
        # };
    };
}
