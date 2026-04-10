# Home Manager defaults shared by all homes
{ den, ... }:
{
  den.aspects.home-base.homeManager =
    { config, ... }:
    {
      home = {
        preferXdgDirectories = true;
        sessionVariables = {
          XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
          XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
          XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
          XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
        };
      };

      systemd.user.startServices = "sd-switch";
    };

  den.aspects.fonts.homeManager =
    { pkgs, ... }:
    {
      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = [
            "Noto Sans"
            "Noto Sans CJK"
          ];
          serif = [
            "Noto Sans"
            "Noto Sans CJK"
          ];
          monospace = [ "JetBrainsMono Nerd Font" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };

      home.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        nerd-fonts.jetbrains-mono
      ];
    };
}

