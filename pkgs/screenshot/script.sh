SCREENSHOTS_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$SCREENSHOTS_DIR"

FILE_NAME="Screenshot_$(date '+%Y-%m-%d_%H-%M-%S-%3N')"

SCREENSHOT_PATH="$SCREENSHOTS_DIR/$FILE_NAME.png"
ANNOTATED_PATH="$SCREENSHOTS_DIR/${FILE_NAME}_annotated.png"

notify() {
    action=$(notify-send \
        --app-name=screenshot \
        --hint=string:image-path:"$SCREENSHOT_PATH" \
        --action=COPY="Copy" \
        --action=EDIT="Edit" \
        "Screenshot Captured")

    case "$action" in
        COPY)
            wl-copy --type image/png < "$SCREENSHOT_PATH"
            ;;
        EDIT)
            satty \
                --filename "$SCREENSHOT_PATH" \
                --output-filename "$ANNOTATED_PATH" \
                --actions-on-enter save-to-clipboard,save-to-file,exit
            ;;
    esac
}

case "${1:-}" in
    fullscreen)
        grim "$SCREENSHOT_PATH"
        notify
        ;;
    region)
        geometry="$(slurp -o)" || exit
        grim -g "$geometry" "$SCREENSHOT_PATH"
        notify
        ;;
    *)
        echo "Usage: screenshot {fullscreen,region}"
        exit 1
        ;;
esac
