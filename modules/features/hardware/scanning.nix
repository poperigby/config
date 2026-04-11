{ den, ... }:
{
    den.aspects.hardware.provides.scanning.nixos =
        { pkgs, ... }:
        {
            hardware.sane = {
                enable = true;
                extraBackends = [ pkgs.epkowa ];
            };

            environment.systemPackages = [ pkgs.kdePackages.skanpage ];
        };
}
