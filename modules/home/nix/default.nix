{ config, lib, ... }:

let
  cfg = config.poperigby.nix;
in
{
    options.poperigby.nix.enable = lib.mkEnableOption "Nix tweaks";

    config = lib.mkIf cfg.enable {
        # This has to be enabled here too: https://github.com/NixOS/nix/issues/8508
        nix.gc = {
            automatic = true;
            options = "--delete-older-than 7d";
        };
    };
}
