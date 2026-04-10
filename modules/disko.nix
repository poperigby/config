# Make `disko.*` options available where drive layout modules are imported.
{ den, inputs, ... }:
{
  den.default.nixos.imports = [ inputs.disko.nixosModules.disko ];
}

