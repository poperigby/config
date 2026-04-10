{ den, inputs, ... }:
{
  flake-file.inputs.jj-starship.url = "github:dmmulroy/jj-starship";

  den.aspects.programs.provides.starship.homeManager =
    { lib, pkgs, ... }:
    let
      inherit (lib) getExe;
    in
    {
      programs.starship = {
        enable = true;
        settings = {
          add_newline = true;
          format = "$all";
          right_format = "$cmd_duration";
          command_timeout = 1000;
          custom.jj = {
            description = "Current jj status";
            command = "${getExe inputs.jj-starship.packages.${pkgs.system}.jj-starship}";
            when = "jj root";
            format = "[$output]($style) ";
            style = "purple";
          };
        };
      };
    };
}
