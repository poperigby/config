{ ... }:
{
    den.aspects.services.provides.virtualization.nixos.virtualisation.libvirtd.enable = true;
    den.aspects.services.provides.virt-manager.nixos.programs.virt-manager.enable = true;

    den.aspects.services.provides.virtualization.user.extraGroups = [
        "libvirtd"
        "docker"
    ];
}
