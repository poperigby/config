{ inputs, ... }:
let
  src = inputs.private-config.outPath;
  privateInfo = (import (src + "/modules/private-info.nix") { }).den.aspects.privateInfo;
in
{
  imports = [
    (src + "/modules/sops.nix")
  ];

  # Make the private info available to both NixOS and Home Manager modules as a module argument.
  den.default = {
    nixos._module.args.privateInfo = privateInfo;
    homeManager._module.args.privateInfo = privateInfo;
  };
}
