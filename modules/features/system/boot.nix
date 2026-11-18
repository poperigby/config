{ inputs, ... }:
{
    flake-file.inputs = {
        lanzaboote = {
            url = "github:nix-community/lanzaboote";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    den.aspects.system.provides.boot =
        {
            secureBoot ? false,
        }:
        {
            nixos =
                { lib, pkgs, ... }:
                {
                    # Import unconditionally so `boot.lanzaboote.*` options exist even when disabled.
                    imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

                    boot = lib.mkMerge [
                        (lib.mkIf secureBoot {
                            lanzaboote = {
                                enable = true;
                                pkiBundle = "/etc/secureboot";
                                # Keys are generated on first boot if missing. Enrollment is staged on the
                                # ESP and applied by systemd-boot when the firmware is in setup mode.
                                autoGenerateKeys.enable = true;
                                autoEnrollKeys.enable = true;
                            };

                            loader.systemd-boot.enable = false;
                        })
                        (lib.mkIf (!secureBoot) {
                            loader.systemd-boot = {
                                enable = true;
                                memtest86.enable = true;
                            };
                            loader.efi.canTouchEfiVariables = true;
                        })
                    ];

                    environment.systemPackages = (if secureBoot then [ pkgs.sbctl ] else [ ]);
                };
        };
}
