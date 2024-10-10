{ ... }:

{
    poperigby = {
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
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home.stateVersion = "23.11";
}
