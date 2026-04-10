# Make `disko.*` options available where drive layout modules are imported.
{ den, inputs, ... }:
{
  flake-file.inputs.disko.url = "github:nix-community/disko";

  den.default.nixos.imports = [ inputs.disko.nixosModules.disko ];
}
