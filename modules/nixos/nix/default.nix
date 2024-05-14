{ config, lib, ... }:

let
  cfg = config.poperigby.nix;
in
{
    options.poperigby.nix.enable = lib.mkEnableOption "Enable Nix tweaks";

    config = lib.mkIf cfg.enable {
        nix = {
            settings = {
                # Enable New CLI and Flakes
                experimental-features = [ "nix-command" "flakes" ];
                # Automatically detects files in the store that have identical contents,
                # and replaces them with hard links to a single copy.
                auto-optimise-store = true;
            };
            # Perform garbage collection weekly to maintain low disk usage
            gc = {
                automatic = true;
                dates = "weekly";
                options = "--delete-older-than 1w";
            };
        };
    };
}
