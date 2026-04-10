# Provide the `services.ucodenix.*` module.
{ den, inputs, ... }:
{
  flake-file.inputs.ucodenix.url = "github:e-tho/ucodenix";

  den.default.nixos.imports = [ inputs.ucodenix.nixosModules.default ];
}
