# Nix configuration (both NixOS + Home Manager)
{ den, ... }:
{
    den.aspects.nix = {
        nixos =
            { pkgs, ... }:
            {
                nix = {
                    # Use Lix, for a better experience
                    # https://lix.systems
                    package = pkgs.lix;

                    settings = {
                        experimental-features = [
                            "flakes"
                            "nix-command"
                        ];

                        # Only allow users in the `wheel` group to access Nix
                        allowed-users = [ "@wheel" ];

                        substituters = [
                            "https://nix-community.cachix.org"
                            "https://devenv.cachix.org"
                        ];

                        trusted-public-keys = [
                            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
                        ];

                        use-xdg-base-directories = true;
                    };

                    optimise.automatic = true;
                };

                programs.nh = {
                    enable = true;
                    clean = {
                        enable = true;
                        extraArgs = "--keep-since 7d --keep 7";
                    };
                };
            };

        homeManager = {
            # https://github.com/NixOS/nix/issues/8508
            nix.gc = {
                automatic = true;
                options = "--delete-older-than 7d";
            };
        };
    };
}
