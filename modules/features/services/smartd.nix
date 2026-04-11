{ den, ... }:
{
    den.aspects.services.provides.smartd.nixos =
        { pkgs, ... }:
        {
            services.smartd.enable = true;
            environment.systemPackages = [ pkgs.smartmontools ];
        };
}
