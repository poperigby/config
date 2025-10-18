{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.jujutsu;
in
{
  options.custom.programs.jujutsu.enable = mkEnableOption "Enable jujutsu";

  config = mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        name = config.privateInfo.poperigby.name;
        email = config.privateInfo.poperigby.email;
      };
    };
  };
}
