{ pkgs, ... }:

{
    custom = {
        suites = {
            common.enable = true;
            gui = {
                enable = true;
                resolution = "2256x1504";
                scale = 1.5;
                refreshRate = 60;
                wallpaper = ./wallpaper.jpg;
            };
        };
        services.swayidle.timeouts = {
            # 10 minutes
            lock = 600;
            # 15 minutes
            sleep = 900;
        };
        programs.thunderbird.enable = true;
        users.cassidy.enable = true;
    };

    home.packages = with pkgs; [
        kdePackages.kdenlive
        openmw
    ];
}
