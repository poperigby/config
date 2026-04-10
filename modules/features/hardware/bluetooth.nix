{ den, ... }:
{
  den.aspects.hardware.provides.bluetooth.nixos = {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}

