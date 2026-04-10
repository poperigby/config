{ den, inputs, ... }:
{
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
