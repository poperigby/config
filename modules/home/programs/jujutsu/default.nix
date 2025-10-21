{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.jujutsu;
in
{
  options.custom.programs.jujutsu.enable = mkEnableOption "jujutsu";

  config = mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = config.privateInfo.poperigby.name;
          email = config.privateInfo.poperigby.email;
        };
        ui = {
          default-command = [ "status" ];
        };
        aliases = {
          tug = [
            "util"
            "exec"
            "--"
            "sh"
            "-c"
            ''
              if [ "x$1" = "x" ]; then
                jj bookmark move --from "closest_bookmark(@)" --to "closest_pushable(@)"
              else
                jj bookmark move --to "closest_pushable(@)" "$@"
              fi
            ''
            ""
          ];
        };
        revset-aliases = {
          "closest_bookmark(to)" = "heads(::to & bookmarks())";
          "closest_pushable(to)" = ''
            heads(::to & mutable() & ~description(exact:" ") & (~empty() | merges()))
          '';
        };
      };
    };
  };
}
