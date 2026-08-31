{ ... }:

{
    den.aspects.programs.provides.morrowind.homeManager =
        {
            pkgs,
            ...
        }:
        {
            home.packages = with pkgs; [
                openmw
                tes3cmd
            ];
        };
}
