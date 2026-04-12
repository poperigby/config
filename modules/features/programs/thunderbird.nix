{ ... }:
{
    den.aspects.programs.provides.thunderbird.homeManager =
        { config, pkgs, ... }:
        let
            user = config.home.username;
        in
        {
            programs.thunderbird = {
                enable = true;
                package = pkgs.thunderbird-latest;
                profiles.cassidy = {
                    isDefault = true;
                    settings = {
                        "font.name-list.emoji" = "emoji";
                        "extensions.autoDisableScopes" = 0;
                    };
                };
            };

            accounts = {
                contact.accounts.${user}.thunderbird.enable = true;
                email.accounts.${user}.thunderbird.enable = true;
            };
        };
}
