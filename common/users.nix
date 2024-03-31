{ config, ... }:

{
    sops.secrets."common/passwords/cassidy".neededForUsers = true;

    # Don't allow changing users with normal commands, allowing Nix to
    # be the single source of truth for users.
    users.mutableUsers = false;

    # Set up me :)
    users.users.cassidy = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."common/passwords/cassidy".path;
        extraGroups = [ "wheel" ];
    };
}
