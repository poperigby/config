{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.custom.nix;
in
{
  options.custom.nix.enable = mkEnableOption "Nix tweaks";

  config = mkIf cfg.enable {
    nix = {
      # Use Lix, for a better experience
      # https://lix.systems
      package = pkgs.lix;

      settings = {
        # Enable New CLI and Flakes
        experimental-features = [
          "flakes"
          "nix-command"
          "repl-flake"
        ];
        # Only allow users in the `wheel` group to access Nix
        allowed-users = [ "@wheel" ];
        # Extra binary caches
        substituters = [
          "https://cache.haddock.cc"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.haddock.cc:jmMvVI/LPS/QPvXwUO0VM5deTAc9l+Dxk1e2r8iqAig="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
      # Every day, detects files in the store that have identical contents,
      # and replaces them with hard links to a single copy.
      # See here for why this is done daily instead of constantly: https://github.com/NixOS/nix/issues/6033
      optimise.automatic = true;
      # Perform garbage collection weekly to maintain low disk usage
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
  };
}
