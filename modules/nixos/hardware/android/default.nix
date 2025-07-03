{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe'
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.hardware.android;
in
{
  options.custom.hardware.android = {
    enable = mkEnableOption "Android debugging";
  };

  config = mkIf cfg.enable {
    programs.adb.enable = true;

    environment = {
      shellAliases.adb = "${getExe' pkgs.android-tools "adb"} HOME=$XDG_DATA_HOME/android adb";
      variables.ANDROID_USER_HOME = "$XDG_DATA_HOME/android";
    };
  };
}
