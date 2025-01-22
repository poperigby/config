{ config, lib, ... }:

let
  cfg = config.custom.programs.bat;
in
{
  options.custom.programs.bat.enable = lib.mkEnableOption "Enable bat";

  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config = {
        theme = "gruvbox-dark";
        # Don't show none of them fancy pants line numbers or such 🤠
        plain = true;
      };
    };
  };
}
