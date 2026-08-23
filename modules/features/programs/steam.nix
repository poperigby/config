{ inputs, ... }:
{
    flake-file.inputs = {
        proton-cachyos = {
            url = "github:Daaboulex/proton-cachyos-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        millennium.url = "github:NixOS/nixpkgs/pull/538226/head";
    };

    den.aspects.programs.provides.steam = {
        nixos =
            { inputs', pkgs, ... }:
            let
                millennium = pkgs.callPackage (inputs.millennium + "/pkgs/by-name/mi/millennium/package.nix") { };
                steamWithMillennium =
                    pkgs.callPackage (inputs.millennium + "/pkgs/by-name/st/steamWithMillennium/package.nix")
                        {
                            inherit millennium;
                        };
            in
            {
                programs = {
                    steam = {
                        enable = true;
                        package = steamWithMillennium;
                        extraCompatPackages = with pkgs; [
                            inputs'.proton-cachyos.packages.default
                            proton-ge-bin
                        ];
                        # Enables the Steam Controller to control the desktop cursor
                        extest.enable = true;
                    };
                    gamemode.enable = true;
                    gamescope = {
                        enable = true;
                        capSysNice = true;
                        enableWsi = true;
                    };
                };

                hardware.steam-hardware.enable = true;
            };
    };
}
