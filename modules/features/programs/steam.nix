{
    flake-file.inputs.proton-cachyos = {
        url = "github:Daaboulex/proton-cachyos-nix";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    den.aspects.programs.provides.steam = {
        nixos = { inputs', pkgs, ... }: {
            programs = {
                steam = {
                    enable = true;
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
