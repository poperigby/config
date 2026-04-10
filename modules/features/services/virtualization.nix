{ den, ... }:
{
  den.aspects.services.provides.virtualization.nixos.virtualisation.libvirtd.enable = true;
  den.aspects.services.provides.virt-manager.nixos.programs.virt-manager.enable = true;

  den.aspects.services.provides.virtualization.provides.cassidy.user.extraGroups = [ "libvirtd" ];
}

