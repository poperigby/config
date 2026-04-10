# Provide the `services.ucodenix.*` module.
{ den, inputs, ... }:
{
  den.default.nixos.imports = [ inputs.ucodenix.nixosModules.default ];
}

