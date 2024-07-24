{ config, ... }:

{
    sops.secrets."common/users/root/password".neededForUsers = true;

    # Set up administrator
    users.users.root.hashedPasswordFile = config.sops.secrets."common/users/root/password".path;
}
