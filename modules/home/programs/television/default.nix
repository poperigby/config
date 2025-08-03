{

  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.television;
in
{
  options.custom.programs.television.enable = mkEnableOption "Television fuzzy finder";

  config = mkIf cfg.enable {
    programs.television = {
      enable = true;
      settings = {
        ui = {
          use_nerd_font_icons = true;
        };
      };
      channels = {
        env = {
          metadata = {
            name = "env";
            description = "A channel to select from environment variables";
          };
          source = {
            command = "printenv";
            output = "{split:=:1..}";
          };
          preview.command = "echo '{split:=:1..}'";
          ui = {
            layout = "portrait";
            preview_panel = {
              size = 20;
              header = "{split:=:0}";
            };
          };
          keybindings.shortcut = "f3";
        };
      };
    };
  };
}
