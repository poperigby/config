{ den, ... }:
{
  den.aspects.services.provides.swaync.homeManager =
    { pkgs, ... }:
    {
      services.swaync = {
        enable = true;
        settings = {
          control-center-width = 600;
          control-center-height = 900;
          fit-to-screen = false;
          widgets = [
            "title"
            "dnd"
            "volume"
            "mpris"
            "backlight"
            "buttons-grid"
            "inhibitors"
            "notifications"
          ];
          widget-config = {
            title.text = "Control Center";
            volume.label = " ";
            backlight.label = "󰃞 ";
            buttons-grid.actions = [
              (
                let
                  sh = "${pkgs.bash}/bin/sh";
                  nmcli = "${pkgs.networkmanager}/bin/nmcli";
                in
                {
                  label = " ";
                  type = "toggle";
                  active = true;
                  command = ''
                    ${sh} -c '[[ $SWAYNC_TOGGLE_STATE == true ]] && ${nmcli} radio wifi on || ${nmcli} radio wifi off'
                  '';
                  update-command = ''
                    ${sh} -c '[[ $(${nmcli} radio wifi) == "enabled" ]] && echo true || echo false'
                  '';
                }
              )
            ];
          };
        };
      };

      # Required for icons to display correctly
      home.packages = [ pkgs.adwaita-icon-theme ];
    };
}

