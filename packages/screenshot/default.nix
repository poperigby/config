{
  grim,
  jq,
  lib,
  libnotify,
  slurp,
  sway,
  writeShellScriptBin,
  xdg-user-dirs,
  ...
}:

let
  inherit (lib)
    getExe
    getExe'
    ;

  grim' = getExe grim;
  notify = "${getExe' libnotify "notify-send"} -a Screenshot -u low -i camera-photo";
  swaymsg = getExe' sway "swaymsg";
  xdg-user-dir = getExe' xdg-user-dirs "xdg-user-dir";
in
writeShellScriptBin "screenshot" ''
  set -euo pipefail

  COMMAND="$1"

  NAME="$(date +'Screenshot_%Y-%m-%d_%H-%M-%S-%N.png')"
  LOCATION="$(${xdg-user-dir} PICTURES)/Screenshots/$NAME";

  case "$COMMAND" in
      fullscreen)
          ${grim'} $LOCATION
          ${notify} "Screenshot saved"
          ;;
      region)
          ${grim'} -g "$(${getExe slurp})" $LOCATION
          ${notify} "Screenshot saved"
          ;;
      focused)
          ${grim'} -g "$(
              ${swaymsg} -t get_tree |
              ${getExe jq} -j '
                  .. |
                  select(.type?) |
                  select(.focused).rect |
                  "\(.x),\(.y) \(.width)x\(.height)"
              '
          )" $LOCATION
          ${notify} "Screenshot saved"
          ;;
      *)
          echo "Unknown command: $COMMAND"
          echo "Usage: screenshot {fullscreen|region|focused}"
          exit 1
          ;;
  esac
''
