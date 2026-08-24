{ ... }:
{
    den.aspects.programs.provides.codex = {
        homeManager =
            {
                config,
                lib,
                pkgs,
                ...
            }:
            let
                inherit (lib) getExe;

                codex = getExe config.programs.codex.package;
            in
            {
                programs.codex = {
                    enable = true;
                    # Keep config.toml unmanaged so Codex can persist local trust decisions there.
                    profiles.default = {
                        approval_policy = "on-request";
                        sandbox_mode = "workspace-write";
                        model = "gpt-5.5";
                        personality = "pragmatic";
                        model_reasoning_effort = "medium";
                        approvals_reviewer = "auto_review";

                        sandbox_workspace_write.network_access = true;

                        notice.model_migrations = {
                            "gpt-5.2-codex" = "gpt-5.4";
                            "gpt-5.4" = "gpt-5.5";
                        };

                        tui = {
                            notifications = false;
                            model_availability_nux = {
                                "gpt-5.5" = 4;
                                "gpt-5.6-sol" = 2;
                            };
                        };

                        mcp_servers.nixos.command = getExe pkgs.mcp-nixos;
                    };
                };

                programs.fish.functions.codex = {
                    wraps = "codex";
                    description = "Run Codex with the default profile";
                    body = # fish
                        ''
                            ${codex} --profile default $argv
                        '';
                };
            };

        provides.gui.homeManager =
            { lib, pkgs, ... }:
            let
                inherit (lib) getExe;

                codexNotify = pkgs.writeShellApplication {
                    name = "codex-notify";
                    runtimeInputs = with pkgs; [
                        jq
                        libnotify
                        niri
                    ];
                    text = # bash
                        ''
                            if [[ -z "''${DBUS_SESSION_BUS_ADDRESS:-}" || ( -z "''${DISPLAY:-}" && -z "''${WAYLAND_DISPLAY:-}" ) ]]; then
                              exit 0
                            fi

                            if focused_window="$(niri msg --json focused-window 2>/dev/null)"; then
                              focused_app_id="$(jq -r '.app_id // empty' <<<"$focused_window")"
                              if [[ "$focused_app_id" == "org.wezfurlong.wezterm" ]]; then
                                exit 0
                              fi
                            fi

                            if [[ $# -gt 0 ]]; then
                              payload="$1"
                            else
                              payload="$(cat)"
                            fi

                            event="$(jq -r '.type // .hook_event_name // empty' <<<"$payload")"

                            case "$event" in
                              agent-turn-complete)
                                body="$(jq -r '."last-assistant-message" // "Turn complete"' <<<"$payload")"
                                notify-send \
                                  --app-name=Codex \
                                  --urgency=normal \
                                  --icon=utilities-terminal \
                                  "Codex" \
                                  "$body" \
                                  >/dev/null 2>&1 || true
                                ;;
                              PermissionRequest)
                                if ! jq -e '
                                  [
                                    .manual_approval_required,
                                    .requires_manual_approval,
                                    .requires_user_approval,
                                    (.approval_kind == "manual"),
                                    (.approval.kind == "manual"),
                                    (.approval.mode == "manual"),
                                    (.review.requires_manual_approval),
                                    (.review.outcome == "manual_approval_required"),
                                    (.review_result == "manual_approval_required")
                                  ] | any
                                ' <<<"$payload" >/dev/null; then
                                  exit 0
                                fi

                                tool="$(jq -r '.tool_name // "tool"' <<<"$payload")"
                                detail="$(jq -r '.tool_input.description // .tool_input.command // "Approval required"' <<<"$payload")"
                                notify-send \
                                  --app-name=Codex \
                                  --urgency=normal \
                                  --icon=dialog-password \
                                  "Codex approval required" \
                                  "$tool: $detail" \
                                  >/dev/null 2>&1 || true
                                ;;
                            esac
                        '';
                };
            in
            {
                programs.codex = {
                    profiles.default.notify = [ (getExe codexNotify) ];
                };
            };
    };
}
