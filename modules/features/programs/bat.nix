{ den, ... }:
{
    den.aspects.programs.provides.bat.homeManager.programs.bat = {
        enable = true;
        config = {
            pager = "less -FR";
            theme = "gruvbox-dark";
        };
    };
}
