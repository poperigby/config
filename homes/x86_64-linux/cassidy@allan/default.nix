{ ... }:

{
    poperigby = {
        suites = {
            common.enable = true;
            gui = {
                enable = true;
                wallpaper = ./wallpaper.jpg;
            };
        };
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home.stateVersion = "23.11";
}
