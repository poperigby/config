{ config, ... }:

{
  custom = {
    # Haddock's config directory isn't in the default spot
    configDir = "${config.home.homeDirectory}/nixos";
    suites = {
      common.enable = true;
    };
  };

  # For CrowdSec
  programs.fish.shellAliases.cs = "sudo cscli";
}
