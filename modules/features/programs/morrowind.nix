{ den, inputs, ... }:
{
  flake-file.inputs = {
    openmw-nix = {
      url = "git+https://codeberg.org/PopeRigby/openmw-nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  den.aspects.programs.provides.morrowind.homeManager =
    { pkgs, ... }:
    {
      home.packages =
        (with pkgs; [
          openmw
          tes3cmd
        ])
        ++ (with inputs.openmw-nix.packages.${pkgs.system}; [
          openmw-validator
        ]);
    };
}
