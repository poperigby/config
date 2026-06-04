{ den, ... }:
{
    den.aspects.cassidy = {
        includes = [
            den._.primary-user
            (den._.user-shell "fish")
        ];

        # OS user attributes (forwarded via Den's built-in `user` class).
        user =
            {
                config,
                privateInfo,
                ...
            }:
            {
                hashedPasswordFile = config.sops.secrets."common/users/cassidy/password".path;
                description = privateInfo.cassidy.name;
                extraGroups = [
                    # Additional groups are provided per-host via mutual providers.
                ];
            };

        nixos.sops.secrets."common/users/cassidy/password".neededForUsers = true;

        # User-specific Home Manager configuration shared across all hosts.
        homeManager =
            {
                config,
                privateInfo,
                ...
            }:
            {
                accounts = {
                    calendar.accounts.cassidy.remote = {
                        type = "caldav";
                        url = "https://dav.haddock.cc/caldav/principal/cassidy/default";
                        userName = "cassidy";
                        passwordCommand = "cat " + config.sops.secrets."common/users/cassidy/dav/password".path;
                    };
                    contact.accounts.cassidy.remote = {
                        type = "carddav";
                        url = "https://dav.haddock.cc/carddav/principal/cassidy/default/";
                        userName = "cassidy";
                        passwordCommand = "cat " + config.sops.secrets."common/users/cassidy/dav/password".path;
                    };
                    email.accounts.cassidy = rec {
                        primary = true;

                        realName = privateInfo.poperigby.name;
                        address = privateInfo.poperigby.email;
                        aliases = [
                            {
                                realName = privateInfo.cassidy.name;
                                address = privateInfo.cassidy.email;
                            }
                        ];
                        passwordCommand = "cat " + config.sops.secrets."common/users/cassidy/email/password".path;

                        userName = address;
                        imap = {
                            host = "imap.mailbox.org";
                            port = 993;
                        };
                        smtp = {
                            host = "smtp.mailbox.org";
                            port = 465;
                        };
                    };
                };

                sops.secrets = {
                    "common/users/cassidy/email/password" = { };
                    "common/users/cassidy/dav/password" = { };
                };
            };
    };
}
