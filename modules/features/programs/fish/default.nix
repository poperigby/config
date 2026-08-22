{ ... }:
{
    den.aspects.programs.provides.fish.homeManager =
        { pkgs, lib, ... }:
        let
            inherit (lib) getExe getExe';
        in
        {
            programs = {
                fish = {
                    enable = true;
                    plugins = with pkgs.fishPlugins; [
                        {
                            name = "autopair";
                            src = autopair.src;
                        }
                        {
                            name = "done";
                            src = pkgs.applyPatches {
                                src = done.src;
                                patches = [ ./done-wezterm-notify-send.patch ];
                            };
                        }
                    ];
                    interactiveShellInit = ''
                        # Use fish for `nix shell` and `nix develop`
                        ${getExe pkgs.nix-your-shell} fish | source

                        # Keybinds
                        bind ctrl-e 'yy; commandline -f repaint'
                        bind ctrl-g ${getExe pkgs.lazygit}
                        bind ctrl-j ${getExe pkgs.lazyjj}
                    '';
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
                # Bash compatibility layer
                packages = [ pkgs.reef ];
                sessionVariables.fish_greeting = "";
            };
        };

}
