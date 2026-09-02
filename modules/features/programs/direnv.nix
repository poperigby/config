{ inputs, ... }:

{
    flake-file.inputs.direnv-instant.url = "github:Mic92/direnv-instant";

    den.aspects.programs.provides.direnv.homeManager = {
        imports = [ inputs.direnv-instant.homeModules.direnv-instant ];

        programs = {
            direnv = {
                enable = true;

                enableBashIntegration = false;
                enableFishIntegration = false;

                nix-direnv.enable = true;
            };
            direnv-instant = {
                enable = true;

                enableBashIntegration = true;
                enableFishIntegration = true;
            };
        };
    };
}
