{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    readFile
    ;

  cfg = config.custom.programs.firefox;
in
{
  options.custom.programs.firefox.enable = mkEnableOption "Firefox";

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles.cassidy = {
        search = {
          default = "ddg";
          privateDefault = "ddg";
          # We don't want Firefox overwriting our search configuration on launch
          force = true;
        };
        userChrome = readFile ./userChrome.css;
        settings = {
          # Allow loading userChrome.css for styling
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          # Use system emoji font
          "font.name-list.emoji" = "emoji";
          # Don't warn about changing about:config settings
          "browser.aboutConfig.showWarning" = false;
          # Use XDG Desktop Portals for various things
          "widget.use-xdg-desktop-portal.file-picker" = 1;
          # Enable Browser Toolbox
          "devtools.chrome.enabled" = true;
          "devtools.debugger.remote-enabled" = true;
          # Set theme to Gruvbox Dark
          "extensions.activeThemeID" = "{eb8c4a94-e603-49ef-8e81-73d3c4cc04ff}";
          # This is a monster 👹
          "browser.uiCustomization.state" = {
            placements = {
              widget-overflow-fixed-list = [ ];
              unified-extensions-area = [
                "ublock0_raymondhill_net-browser-action"
                "sponsorblocker_ajay_app-browser-action"
                "addon_fastforward_team-browser-action"
                "_74145f27-f039-47ce-a470-a662b129930a_-browser-action"
                "private-relay_firefox_com-browser-action"
                "_cb31ec5d-c49a-4e5a-b240-16c767444f62_-browser-action"
                "cors-everywhere_spenibus-browser-action"
                "_e58d3966-3d76-4cd9-8552-1582fbc800c1_-browser-action"
                "cb-remover_search_mozilla_org-browser-action"
                "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action"
                "_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action"
              ];
              nav-bar = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "urlbar-container"
                "downloads-button"
                "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
                "tab-stash_condordes_net-browser-action"
                "unified-extensions-button"
                "reset-pbm-toolbar-button"
                "dearrow_ajay_app-browser-action"
              ];
              toolbar-menubar = [ "menubar-items" ];
              TabsToolbar = [
                "tabbrowser-tabs"
                "new-tab-button"
                "alltabs-button"
              ];
              PersonalToolbar = [ "personal-bookmarks" ];
            };
            seen = [
              "save-to-pocket-button"
              "developer-button"
              "_74145f27-f039-47ce-a470-a662b129930a_-browser-action"
              "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
              "sponsorblocker_ajay_app-browser-action"
              "tab-stash_condordes_net-browser-action"
              "addon_fastforward_team-browser-action"
              "ublock0_raymondhill_net-browser-action"
              "private-relay_firefox_com-browser-action"
              "_cb31ec5d-c49a-4e5a-b240-16c767444f62_-browser-action"
              "dearrow_ajay_app-browser-action"
              "cors-everywhere_spenibus-browser-action"
              "_e58d3966-3d76-4cd9-8552-1582fbc800c1_-browser-action"
              "cb-remover_search_mozilla_org-browser-action"
              "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action"
              "_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action"
            ];
            dirtyAreaCache = [
              "nav-bar"
              "PersonalToolbar"
              "toolbar-menubar"
              "TabsToolbar"
              "widget-overflow-fixed-list"
              "unified-extensions-area"
            ];
            currentVersion = 20;
            newElementCount = 4;
          };
        };
      };
    };
    xdg.mimeApps.defaultApplications = {
      "application/pdf" = "firefox.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };
  };
}
