declare -A seen_windows=()

mark_seen() {
	while IFS= read -r id; do
		[[ -n "$id" ]] && seen_windows["$id"]=1
	done
}

niri msg --json event-stream |
	jq -c --unbuffered 'select(has("WindowsChanged") or has("WindowOpenedOrChanged"))' |
	while IFS= read -r event; do
		if jq -e 'has("WindowsChanged")' <<<"$event" >/dev/null; then
			mark_seen < <(jq -r '.WindowsChanged.windows[].id' <<<"$event")
			continue
		fi

		window="$(jq -c '.WindowOpenedOrChanged.window' <<<"$event")"
		id="$(jq -r '.id' <<<"$window")"

		if [[ -n "${seen_windows[$id]:-}" ]]; then
			continue
		fi
		seen_windows["$id"]=1

		if [[ "$(jq -r '.is_floating' <<<"$window")" == "true" ]]; then
			continue
		fi

		workspace_id="$(jq -r '.workspace_id // empty' <<<"$window")"
		if [[ -z "$workspace_id" ]]; then
			continue
		fi

		tiled_window_count="$(
			niri msg --json windows |
				jq --argjson workspace_id "$workspace_id" \
					'[.[] | select(.workspace_id == $workspace_id and .is_floating == false)] | length'
		)"

		if [[ "$tiled_window_count" == "1" ]]; then
			niri msg action set-window-width --id "$id" "100%"
		fi
	done
