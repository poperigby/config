{ den, ... }:
{
  den.aspects.desktops.provides.cosmic.nixos.services = {
    desktopManager.cosmic.enable = true;
    displayManager.cosmic-greeter.enable = true;
  };
}

