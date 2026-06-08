{ ... }:

{
    den.aspects.system.provides.plymouth.nixos = { pkgs, ... }: {
        boot = {
            plymouth = {
                enable = true;
                theme = "nixos-bgrt";
                themePackages = [ pkgs.nixos-bgrt-plymouth ];
            };
            kernelParams = [ "quiet" ];
        };
    };
}
