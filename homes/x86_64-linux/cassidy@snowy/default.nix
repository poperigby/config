{ ... }:

{
    poperigby = {
        suites = {
            common.enable = true;
            gaming.enable = true;
            gui = {
                enable = true;
                adaptiveSync = true;
                resolution = "2560x1440";
                refreshRate = 165;
                wallpaper = ./wallpaper.jpg;
            };
        };
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home.stateVersion = "23.11";
}
