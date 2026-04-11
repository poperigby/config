{ den, ... }:
{
    den.aspects.hardware.provides.audio.nixos.services.pipewire = {
        enable = true;
        audio.enable = true;
        wireplumber.enable = true;
        alsa = {
            enable = true;
            support32Bit = true;
        };
        pulse.enable = true;
    };
}
