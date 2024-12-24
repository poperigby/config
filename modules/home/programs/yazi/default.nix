{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkMerge
    optionals
    readFile
    ;

  cfg = config.poperigby.programs.yazi;
  gui = config.poperigby.suites.gui.enable;
in
{
  options.poperigby.programs.yazi = {
    enable = mkEnableOption "Yazi file explorer";
    default = mkEnableOption "Yazi as the default file explorer";
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
      theme = fromTOML (readFile ./theme.toml);
      initLua = ./init.lua;
      settings = {
        manager = {
          sort_by = "mtime";
          sort_reverse = true;
          sort_dir_first = false;
        };
        opener = {
          extract = [
            {
              run = "ouch d -y \"$@\"";
              desc = "Extract here with ouch";
              for = "unix";
            }
          ];
        };
        plugin = {
          prepend_previewers = [
            # Archive previewer
            {
              mime = "application/*zip";
              run = "ouch";
            }
            {
              mime = "application/x-tar";
              run = "ouch";
            }
            {
              mime = "application/x-bzip2";
              run = "ouch";
            }
            {
              mime = "application/x-7z-compressed";
              run = "ouch";
            }
            {
              mime = "application/x-rar";
              run = "ouch";
            }
            {
              mime = "application/x-xz";
              run = "ouch";
            }
          ];
        };
      };
      plugins = {
        yamb = pkgs.fetchFromGitHub {
          owner = "h-hg";
          repo = "yamb.yazi";
          rev = "108347b0392fc819af04506dd0405fb744dfca68";
          hash = "sha256-/BU/jVWgLK7JmPQpCHXhPCH+LrLy7RIYyIX0TYbTpuk=";
        };
        ouch = pkgs.fetchFromGitHub {
          owner = "ndtoan96";
          repo = "ouch.yazi";
          tag = "v0.4.0";
          hash = "sha256-eRjdcBJY5RHbbggnMHkcIXUF8Sj2nhD/o7+K3vD3hHY=";
        };
      };
      keymap = {
        manager.prepend_keymap =
          [
            # Ouch archive manager
            {
              on = [ "C" ];
              run = "plugin ouch --args=zip";
              desc = "Compress with ouch";
            }
            # Yamb bookmark manager
            {
              on = [
                "u"
                "a"
              ];
              run = "plugin yamb --args=save";
              desc = "Add bookmark";
            }
            {
              on = [
                "u"
                "g"
              ];
              run = "plugin yamb --args=jump_by_key";
              desc = "Jump bookmark by key";
            }
            {
              on = [
                "u"
                "G"
              ];
              run = "plugin yamb --args=jump_by_fzf";
              desc = "Jump bookmark by fzf";
            }
            {
              on = [
                "u"
                "d"
              ];
              run = "plugin yamb --args=delete_by_key";
              desc = "Delete bookmark by key";
            }
            {
              on = [
                "u"
                "D"
              ];
              run = "plugin yamb --args=delete_by_fzf";
              desc = "Delete bookmark by fzf";
            }
            {
              on = [
                "u"
                "A"
              ];
              run = "plugin yamb --args=delete_all";
              desc = "Delete all bookmarks";
            }
            {
              on = [
                "u"
                "r"
              ];
              run = "plug";
            }
          ]
          ++ optionals gui [
            # Enable mapping for ripdrag if GUI is enabled
            {
              on = [ "<C-n>" ];
              run = "shell '${getExe pkgs.ripdrag} \"$@\" -x 2>/dev/null &' --confirm";
              description = "Open ripdrag for dragging and dropping";
            }
          ];
      };
    };

    # Do some helpful desktop related tweaks if GUI suite is enabled
    xdg = mkIf gui (mkMerge [
      {
        desktopEntries.yazi = {
          name = "Yazi";
          genericName = "File Browser";
          exec = "${getExe pkgs.yazi} %f";
          icon = ./icon.png;
          terminal = true;
          categories = [
            "System"
            "FileTools"
            "FileManager"
          ];
          mimeType = [ "inode/directory" ];
        };
      }
    ]);
  };
}
