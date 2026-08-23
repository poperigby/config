{ den, ... }:
{
    den.aspects.programs.provides.fish.homeManager =
        {
            lib,
            pkgs,
            user,
            ...
        }:
        let
            inherit (lib) getExe getExe';
            hasGui = user.hasAspect.forAnyClass den.aspects.gui;
        in
        {
            programs = {
                fish = {
                    enable = true;
                    plugins =
                        with pkgs.fishPlugins;
                        [
                            {
                                name = "autopair";
                                src = autopair.src;
                            }
                        ]
                        ++ lib.optional hasGui {
                            name = "done";
                            src = pkgs.applyPatches {
                                src = done.src;
                                patches = [ ./done-wezterm-notify-send.patch ];
                            };
                        };
                    interactiveShellInit = # fish
                        ''
                            # Use fish for `nix shell` and `nix develop`
                            ${getExe pkgs.nix-your-shell} fish | source

                            # Keybinds
                            bind ctrl-e 'yy; commandline -f repaint'
                            bind ctrl-g ${getExe pkgs.lazygit}
                            bind ctrl-j ${getExe pkgs.lazyjj}
                        '';
                    functions.sudo = lib.mkIf hasGui {
                        wraps = "sudo";
                        description = "Run sudo and notify when authentication is required";
                        body = # fish
                            ''
                                if not command sudo -n true 2>/dev/null
                                    set -l should_notify 1
                                    if functions -q __done_is_process_window_focused
                                        and __done_is_process_window_focused
                                        set should_notify 0
                                    end

                                    if test "$should_notify" -eq 1
                                        set -l sudo_command (string join ' ' -- (string escape -- $argv))
                                        ${getExe' pkgs.libnotify "notify-send"} \
                                            --app-name=fish \
                                            --icon=${pkgs.noto-fonts-color-emoji.src}/svg/emoji_u1f96a.svg \
                                            --urgency=normal \
                                            "sudo password required" \
                                            "$sudo_command" \
                                            >/dev/null 2>&1
                                    end
                                end

                                command sudo $argv
                            '';
                    };
                };
                # Launch fish from interactive bash sessions (unless already in fish).
                bash = {
                    enable = true;
                    initExtra = # bash
                        ''
                            if [[ $(${getExe' pkgs.procps "ps"} --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]; then
                              shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
                              exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
                            fi
                        '';
                };
            };

            home = {
                packages =
                    with pkgs;
                    [
                        # Bash compatibility layer
                        reef
                    ]
                    ++ lib.optionals hasGui [
                        # So done.fish can send notifications with different urgency
                        libnotify
                    ];
                sessionVariables.fish_greeting = "";
            };
        };
}
