{ den, inputs, ... }:
{
    flake-file.inputs = {
        openmw-nix = {
            url = "git+https://codeberg.org/PopeRigby/openmw-nix.git";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    den.aspects.programs.provides.morrowind.homeManager =
        {
            lib,
            pkgs,
            system,
            ...
        }:
        let
            inherit (lib) getExe getExe';
        in
        {
            home.packages =
                (with pkgs; [
                    openmw
                    tes3cmd
                ])
                ++ (with inputs.openmw-nix.packages.${system}; [
                    delta-plugin
                    groundcoverify
                    openmw-validator
                ]);

            xdg.desktopEntries."org.openmw.launcher" = {
                name = "OpenMW Launcher";
                genericName = "Role Playing Game";
                comment = "An engine replacement for The Elder Scrolls III: Morrowind";
                exec = getExe (
                    pkgs.writeShellScriptBin "openmw-launcher-wrapper" ''
                        # Improve OpenMW performance on AMD systems
                        # https://modding-openmw.com/tips/performance/#os-gpu-specific-tips
                        export OSG_VERTEX_BUFFER_HINT="VERTEX_BUFFER_OBJECT"

                        ${getExe' pkgs.mangohud "mangohud"} ${getExe' pkgs.openmw "openmw-launcher"}
                    ''
                );
                icon = "openmw";
                type = "Application";
                categories = [
                    "Game"
                    "RolePlaying"
                ];
                settings.Keywords = "Morrowind;Reimplementation;Mods;esm;bsa";
            };
        };
}
