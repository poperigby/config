{ config, ... }:

{
    sops.secrets."common/passwords/cassidy".neededForUsers = true;

    # Set up me :)
    users.users.cassidy = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."common/passwords/cassidy".path;
        extraGroups = [ "wheel" ];
    };
}
