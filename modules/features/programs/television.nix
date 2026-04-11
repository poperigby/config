{ den, ... }:
{
    den.aspects.programs.provides.television.homeManager =
        { pkgs, ... }:
        {
            programs.television = {
                enable = true;
                settings = {
                    default_action = "Enter";
                    use_nerd_font_icons = true;
                };
            };
            home.packages = [ pkgs.television ];
        };
}
