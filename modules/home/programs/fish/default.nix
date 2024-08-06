{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.programs.fish;
in
{
    options.poperigby.programs.fish.enable = lib.mkEnableOption "Enable fish";

    config = lib.mkIf cfg.enable {
        programs = {
            fish = {
                enable = true;
                plugins = with pkgs.fishPlugins; [
                    { name = "done"; src = done; }
                    { name = "autopair"; src = autopair; }
                ];
                shellAliases = {
                    cat = "bat";
                    find = "fd";
                    grep = "rg";
                    jrn = "sudo journalctl";
                    lg = "lazygit";
                    py = "python";
                    sys = "sudo systemctl";
                    syu = "systemctl --user";
                    tree = "ls --tree";
                };
                # Use fish for `nix shell` and `nix develop`
                interactiveShellInit = ''
                    ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source
                '';
            };
            # Magnificent app that corrects your previous console command
            thefuck.enable = true;
            # For smart directory changing
            zoxide.enable = true;
            # Setting fish as our default shell causes some issues. Instead, automatically launch fish
            # when we start an interactive bash shell, but only if we're not opening one from fish.
            bash = {
                enable = true;
                initExtra = ''
                    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]; then
                        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
                        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
                    fi
                '';
            };
        };

        # Use Starship for our prompt 🚀 
        poperigby.programs.starship.enable = true;

        # Environment variables
        home.sessionVariables = {
            # The fish greeting is annoying 😡🤜🐟
            fish_greeting = "";
        };
    };
}
