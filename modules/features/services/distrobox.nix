{ den, ... }:
{
    den.aspects.services.provides.distrobox.nixos =
        { pkgs, ... }:
        {
            virtualisation.podman.enable = true;
            environment.systemPackages = [ pkgs.distrobox ];
        };
}
