{
  config,
  inputs,
  lib,
  pkgs,
  system,
  ...
}:

let
  inherit (lib)
    getExe
    getExe'
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.morrowind;
in
{
  options.custom.programs.morrowind.enable = mkEnableOption "OpenMW and modding tools";

  config = mkIf cfg.enable {
    home.packages =
      (with inputs.openmw-nix.packages.${system}; [
        delta-plugin
        groundcoverify
        openmw-validator
        # plox
      ])
      ++ (with pkgs; [
        openmw
      ]);

    xdg.desktopEntries."org.openmw.launcher" = {
      name = "OpenMW Launcher";
      genericName = "Role Playing Game";
      comment = "An engine replacement for The Elder Scrolls III: Morrowind";
      exec = getExe (
        pkgs.writeShellScriptBin "openmw-launcher-wrapper" ''
          # Improve OpenMW performance on AMD systems
          # https://modding-openmw.com/tips/performance/#os-gpu-specific-tips
          export OSG_VERTEX_BUFFER_HINT="VERTEX_BUFFER_OBJECT"

          ${getExe' pkgs.mangohud "mangohud"} ${getExe' pkgs.openmw "openmw-launcher"}
        ''
      );
      icon = "openmw";
      type = "Application";
      categories = [
        "Game"
        "RolePlaying"
      ];
      settings.Keywords = "Morrowind;Reimplementation;Mods;esm;bsa";
    };
  };
}
