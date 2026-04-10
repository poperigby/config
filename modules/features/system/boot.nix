{ den, inputs, ... }:
{
  den.aspects.system.provides.boot =
    { secureBoot ? false }:
    {
      nixos =
        { lib, pkgs, ... }:
        {
          # Import unconditionally so `boot.lanzaboote.*` options exist even when disabled.
          imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

          boot = lib.mkMerge [
            {
              initrd.systemd.enable = true;
            }
            (lib.mkIf secureBoot {
              lanzaboote = {
                enable = true;
                pkiBundle = "/etc/secureboot";
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
