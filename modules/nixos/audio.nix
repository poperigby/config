{ config, lib, ... }:

let
  cfg = config.modules.nixos.audio;
in
{
    options.modules.nixos.audio.enable = lib.mkEnableOption "Enable audio (PipeWire)";

    config = lib.mkIf cfg.enable {
        services.pipewire = {
            enable = true;
            # Use PipeWire as the primary sound server
            audio.enable = true;
            # Enable Wireplumber, a modular session / policy manager
            wireplumber.enable = true;
        };
    };
}
