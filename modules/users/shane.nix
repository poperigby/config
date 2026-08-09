{ den, ... }:
{
    den.aspects.shane = {
        includes = [ den.aspects.programs._.atuin ];

        user =
            { config, ... }:
            {
                hashedPasswordFile = config.sops.secrets."common/users/shane/password".path;
                description = "Shane Wilson";
                extraGroups = [ "wheel" ];
            };

        nixos.sops.secrets."common/users/shane/password".neededForUsers = true;
    };
}
