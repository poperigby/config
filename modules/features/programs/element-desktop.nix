{ den, ... }:
{
  den.aspects.programs.provides.element-desktop.homeManager =
    { lib, pkgs, ... }:
    {
      home.packages = [ pkgs.element-desktop ];
      xdg.configFile."Element/config.json".text = lib.strings.toJSON {
        show_labs_settings = true;
      };
    };
}

