{ den, ... }:
{
  den.aspects.julian = {
    user = { config, ... }: {
      hashedPasswordFile = config.sops.secrets."common/users/julian/password".path;
      description = "Julian Wilson";
      extraGroups = [ "wheel" ];
    };

    nixos.sops.secrets."common/users/julian/password".neededForUsers = true;
  };
}

