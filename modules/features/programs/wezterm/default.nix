{ den, ... }:
{
    den.aspects.programs.provides.wezterm.homeManager =
        { pkgs, ... }:
        {
            programs.wezterm = {
                enable = true;
                extraConfig = builtins.readFile ./config.lua;
            };
            home.packages = [ pkgs.wezterm ];
        };
}
