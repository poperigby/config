{ den, ... }:
{
    den.aspects.programs.provides.swaylock =
        {
            wallpaper ? null,
        }:
        {
            homeManager =
                { pkgs, ... }:
                {
                    programs.swaylock = {
                        enable = true;
                        package = pkgs.swaylock-effects;
                        settings = {
                            clock = true;
                            timestr = "%H:%M";
                            indicator-idle-visible = true;
                            indicator-radius = 100;
                            image = if wallpaper == null then "" else toString wallpaper;
                            effect-blur = "7x5";
                        };
                    };
                };
        };
}
