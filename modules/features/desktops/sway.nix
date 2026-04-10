{ den, ... }:
{
  den.aspects.desktops.provides.sway.nixos = {
    security = {
      polkit.enable = true;
      pam.services.swaylock = { };
    };

    programs.dconf.enable = true;
    hardware.graphics.enable = true;
  };
}

