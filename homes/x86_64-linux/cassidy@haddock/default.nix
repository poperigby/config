{ config, ... }:

{
    poperigby = {
        # Haddock's config directory isn't in the default spot
        configDir = "${config.home.homeDirectory}/nixos";
        suites = {
            common.enable = true;
        };
    };

    # For CrowdSec
    programs.fish.shellAliases.cs = "sudo cscli";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home.stateVersion = "23.11";
}
