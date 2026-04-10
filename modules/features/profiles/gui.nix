{ den, ... }:
{
  den.aspects.gui = {
    includes = [ den.aspects.services._.udisks2 ];

    nixos =
      { pkgs, ... }:
      {
        services.udisks2.enable = true;
        programs.wireshark.enable = true;
        environment.systemPackages = with pkgs; [ wireshark ];
        services.systembus-notify.enable = true;
      };

    provides.user = {
      includes = [
        den.aspects.programs._.discord
        den.aspects.programs._.element-desktop
        den.aspects.programs._.firefox
        den.aspects.programs._.mpv
        den.aspects.programs._.wezterm

        den.aspects.programs._.bottom-gui
        den.aspects.programs._.neovim-gui
        den.aspects.programs._.yazi-gui
      ];

      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            bottles
            gimp3
            inkscape
            libreoffice
            signal-desktop
            tenacity
            tor-browser
            ungoogled-chromium
            wl-clipboard-rs
          ];

          xdg.mimeApps.enable = true;
          home.sessionVariables.NIXOS_OZONE_WL = 1;
        };
    };

    # GUI machines grant some extra groups to Cassidy.
    provides.cassidy.user.extraGroups = [
      "i2c"
      "wireshark"
    ];
  };
}
