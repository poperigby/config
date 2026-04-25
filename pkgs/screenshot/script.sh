set -euo pipefail

if [[ $# -ge 1 ]]; then
    COMMAND="$1"
    shift
else
    echo "Usage: screenshot {fullscreen|region|focused}"
    exit 1
fi


NAME="$(date +'Screenshot_%Y-%m-%d_%H-%M-%S-%N.png')"
LOCATION="$(xdg-user-dir PICTURES)/Screenshots/$NAME";

NOTIFY="notify-send -a Screenshot -u low -i camera-photo"

case "$COMMAND" in
    fullscreen)
        grim "$LOCATION"
        $NOTIFY "Screenshot saved"
        ;;
    region)
        grim -g "$(slurp)" "$LOCATION"
        $NOTIFY "Screenshot saved"
        ;;
    focused)
        grim -g "$(
            swaymsg -t get_tree |
            jq -j '
                .. |
                select(.type?) |
                select(.focused).rect |
                "\(.x),\(.y) \(.width)x\(.height)"
            '
        )" "$LOCATION"
        $NOTIFY "Screenshot saved"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Usage: screenshot {fullscreen|region|focused}"
        exit 1
        ;;
esac
