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
    };
  };
}
