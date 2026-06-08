{ ... }:
{
    den.aspects.security.provides.run0.nixos =
        { lib, ... }:
        {
            security.pam.services.systemd-run0 = { };

            security = {
                run0.enableSudoAlias = true;
                sudo.enable = lib.mkForce false;
            };
        };
}
