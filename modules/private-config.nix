{ inputs, ... }:
let
    src = inputs.private-config.outPath;
    privateInfo = (import (src + "/modules/private-info.nix") { }).den.aspects.privateInfo;
in
{
    flake-file.inputs = {
        private-config.url = "git+ssh://git@codeberg.org/PopeRigby/private-config.git?ref=trunk";
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    imports = [
        (src + "/modules/sops.nix")
    ];

    # Make the private info available to both NixOS and Home Manager modules as a module argument.
    den.default = {
        nixos._module.args.privateInfo = privateInfo;
        homeManager._module.args.privateInfo = privateInfo;
    };
}
