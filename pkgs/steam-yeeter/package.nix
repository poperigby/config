{
    lib,
    pkgs,
    steam ? pkgs.steam,
    ...
}:

pkgs.writeShellApplication {
    name = "steam-yeeter";
    runtimeInputs = with pkgs; [
        coreutils
        jq
        niri
        procps
    ];
    text = ''
        state_dir="''${XDG_RUNTIME_DIR:-/tmp}/steam-yeeter"
        state_file="$state_dir/workspace"
        lock_dir="$state_dir/watch.lock"
        startup_timeout=20s
        steam_process_pattern='(^|/)steam($| )|steamwebhelper'

        mkdir -p "$state_dir"

        if [ -s "$state_file" ] && pgrep -u "$(id -u)" -f "$steam_process_pattern" >/dev/null; then
            origin_workspace="$(cat "$state_file")"
        else
            origin_workspace="$(
                niri msg --json workspaces \
                    | jq -r '.[] | select(.is_focused == true) | .id' \
                    | head -n 1
            )"
            printf '%s\n' "$origin_workspace" > "$state_file"
        fi

        "${lib.getExe steam}" "$@" &
        steam_pid="$!"

        if [ -n "$origin_workspace" ] && mkdir "$lock_dir" 2>/dev/null; then
            (
                trap 'rm -rf "$lock_dir" "$state_file"' EXIT

                # Steam can create windows on whichever workspace is focused
                # during startup, so move each new Steam window back to the
                # workspace where Steam was initially launched.
                handled_windows=" "
                handle_window() {
                    window_id="$1"
                    workspace_id="$2"

                    # Each window ID gets one startup correction at most. After
                    # that, workspace changes are assumed to be intentional.
                    case "$handled_windows" in
                        *" $window_id "*)
                            return
                            ;;
                    esac
                    handled_windows="$handled_windows$window_id "

                    if [ "$workspace_id" != "$origin_workspace" ]; then
                        niri msg action move-window-to-workspace \
                            --window-id "$window_id" \
                            "$origin_workspace" \
                            --focus=false >/dev/null || true
                    fi
                }

                # Niri sends the current window list first, then sends
                # later window open/change events as they happen.
                while IFS="$(printf '\t')" read -r window_id workspace_id; do
                    handle_window "$window_id" "$workspace_id"
                done < <(
                    (
                        timeout "$startup_timeout" niri msg --json event-stream || true
                    ) | jq -r --unbuffered '
                        def steam_window:
                            select(.app_id == "steam")
                            | select(.workspace_id != null)
                            | select((.title // "" | test("^notificationtoasts_\\d+_desktop$")) | not)
                            | [.id, .workspace_id]
                            | @tsv;

                        if type != "object" then
                            empty
                        elif has("WindowsChanged") then
                            .WindowsChanged.windows[] | steam_window
                        elif has("WindowOpenedOrChanged") then
                            .WindowOpenedOrChanged.window | steam_window
                        else
                            empty
                        end
                    '
                )

                while pgrep -u "$(id -u)" -f "$steam_process_pattern" >/dev/null; do
                    sleep 5
                done
            ) &
        fi

        wait "$steam_pid"
    '';
}
