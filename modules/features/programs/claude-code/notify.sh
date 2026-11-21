#!/usr/bin/env bash
# Claude Code hook that sends a desktop notification for Notification and Stop
# events. Reads the hook payload as JSON on stdin.

input=$(cat)

event=$(jq -r '.hook_event_name' <<<"$input")
project=$(basename "$(jq -r '.cwd // empty' <<<"$input")")
urgency=normal

case "$event" in
Notification)
    summary=$(jq -r '.title // "Claude Code"' <<<"$input")
    body=$(jq -r '.message // empty' <<<"$input")
    if [[ $(jq -r '.notification_type // empty' <<<"$input") == permission_prompt ]]; then
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
