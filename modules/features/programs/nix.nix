# Nix configuration (both NixOS + Home Manager)
{ ... }:
{
    den.aspects.programs.provides.nix = {
        nixos =
            { ... }:
            {
                nix = {
                    settings = {
                        experimental-features = [
                            "flakes"
                            "nix-command"
                        ];

                        # Only allow users in the `wheel` group to access Nix
                        allowed-users = [ "@wheel" ];
                        trusted-users = [ "@wheel" ];

                        substituters = [
                            "https://nix-community.cachix.org"
                            "https://nixos-raspberrypi.cachix.org"
                        ];

                        trusted-public-keys = [
                            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                            "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
                        ];

                        # Unreachable binary caches should not block local builds.
                        fallback = true;
                        connect-timeout = 2;
                        download-attempts = 1;
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
