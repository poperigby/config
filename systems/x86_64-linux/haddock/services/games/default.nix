{ inputs, ... }:

{
  imports = [
    # ./insurgency.nix
    ./minecraft
  ];

  flux.enable = true;
  nixpkgs.overlays = [ inputs.flux.overlays.default ];
}
