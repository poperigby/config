#!/usr/bin/env bash
# Claude Code hook that sends a desktop notification for Notification and Stop
# events, unless the WezTerm pane Claude is running in has focus. Reads the hook
# payload as JSON on stdin.

# niri knows which window has focus, and WezTerm knows which of its panes does.
# Outside of niri and WezTerm, the terminal counts as unfocused.
terminal_focused() {
    [[ -n ${NIRI_SOCKET:-} && -n ${WEZTERM_PANE:-} ]] || return 1

    local focused_pid
    focused_pid=$(timeout 1 niri msg --json focused-window | jq '.pid // empty') || return 1
    [[ -n $focused_pid ]] || return 1

    timeout 1 wezterm cli list-clients --format json |
        jq --exit-status \
            --argjson pid "$focused_pid" \
            --argjson pane "$WEZTERM_PANE" \
            'any(.[]; .pid == $pid and .focused_pane_id == $pane)' >/dev/null
}

input=$(cat)

if terminal_focused; then
    exit 0
fi

event=$(jq -r '.hook_event_name' <<<"$input")
project=$(basename "$(jq -r '.cwd // empty' <<<"$input")")
urgency=normal

case "$event" in
Notification)
    type=$(jq -r '.notification_type // empty' <<<"$input")
    # Stop already announces the end of a turn.
    if [[ $type == idle_prompt ]]; then
        exit 0
    fi
    summary=$(jq -r '.title // "Claude Code"' <<<"$input")
    body=$(jq -r '.message // empty' <<<"$input")
    if [[ $type == permission_prompt ]]; then
        urgency=critical
    fi
    ;;
Stop)
    # A Stop hook that blocked the previous stop re-fires with this flag set.
    if [[ $(jq -r '.stop_hook_active' <<<"$input") == true ]]; then
        exit 0
    fi
    summary="Claude Code finished"
    body=$(jq -r '.last_assistant_message // empty' <<<"$input" | head -c 300)
    ;;
*)
    exit 0
    ;;
esac

if [[ -n $project ]]; then
    summary="$summary · $project"
fi

notify-send \
    --app-name="Claude Code" \
    --icon="$CLAUDE_CODE_NOTIFY_ICON" \
    --urgency="$urgency" \
    "$summary" "$body"
