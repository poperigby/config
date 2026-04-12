{ ... }:
{
    den.aspects.hardware.provides.printing.nixos.services = {
        printing.enable = true;
        avahi = {
            enable = true;
            nssmdns4 = true;
            openFirewall = true;
        };
    };

    den.aspects.hardware.provides.printing.provides.to-users.user.extraGroups = [ "lp" ];
}
