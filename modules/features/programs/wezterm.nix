{ den, ... }:
{
  den.aspects.programs.provides.wezterm.homeManager =
    { pkgs, ... }:
    {
      programs.wezterm = {
        enable = true;
        extraConfig = builtins.readFile ../../assets/home/wezterm/config.lua;
      };
      home.packages = [ pkgs.wezterm ];
    };
}

