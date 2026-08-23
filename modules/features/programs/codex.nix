{ ... }:
{
    den.aspects.programs.provides.codex = {
        homeManager = {
            programs.codex = {
                enable = true;
                settings = {
                    approval_policy = "on-request";
                    sandbox_mode = "workspace-write";
                    model = "gpt-5.5";
                    personality = "pragmatic";
                    model_reasoning_effort = "medium";
                    approvals_reviewer = "auto_review";

                    sandbox_workspace_write.network_access = true;

                    projects = {
                        "/home/cassidy/Projects/config".trust_level = "trusted";
                        "/home/cassidy/Projects/barnacle".trust_level = "trusted";
                        "/home/cassidy/Projects/DankCalculator".trust_level = "trusted";
                        "/home/cassidy/.local/share/Steam/steamapps/common/Cyberpunk 2077".trust_level = "trusted";
                        "/home/cassidy/Projects/matrix_dump".trust_level = "trusted";
                        "/home/cassidy/Projects/ledger-bot".trust_level = "trusted";
                        "/home/cassidy/Documents/mug_mold".trust_level = "trusted";
                        "/home/cassidy/Projects/done".trust_level = "trusted";
                    };

                    plugins."canva@openai-curated".enabled = true;

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

                    mcp_servers.nixos = {
                        command = "nix";
                        args = [
                            "run"
                            "github:utensils/mcp-nixos"
                            "--"
                        ];
                    };
                };
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
                    ];
                    text = # bash
                        ''
                            if [[ -z "''${DBUS_SESSION_BUS_ADDRESS:-}" || ( -z "''${DISPLAY:-}" && -z "''${WAYLAND_DISPLAY:-}" ) ]]; then
                              exit 0
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
                    settings.notify = [ (getExe codexNotify) ];

                    hooks.PermissionRequest = [
                        {
                            matcher = ".*";
                            hooks = [
                                {
                                    type = "command";
                                    command = getExe codexNotify;
                                    async = true;
                                    timeout = 3;
                                }
                            ];
                        }
                    ];
                };
            };
    };
}
