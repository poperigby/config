{ pkgs, ... }:

{
    programs.fish = {
        enable = true;
        plugins = [
            {
                name = "tide";
                src = pkgs.fetchFromGitHub {
                    owner = "ilancosman";
                    repo = "tide";
                    rev = "v6.1.1";
                    sha256 = "sha256-ZyEk/WoxdX5Fr2kXRERQS1U1QHH3oVSyBQvlwYnEYyc=";
                };
            }
            {
                name = "done";
                src = pkgs.fetchFromGitHub {
                    owner = "franciscolourenco";
                    repo = "done";
                    rev = "1.19.2";
                    sha256 = "sha256-VSCYsGjNPSFIZSdLrkc7TU7qyPVm8UupOoav5UqXPMk=";
                };
            }
        ];
        shellAliases = {
            cat = "bat";
            grep = "rg";
            jrn = "sudo journalctl";
            lg = "lazygit";
            py = "python";
            sys = "sudo systemctl";
            syu = "systemctl --user";
        };
    };

    # Environment variables
    home.sessionVariables = {
        # The fish greeting is annoying >:(
        fish_greeting = "";
    };

    # Magnificent app that corrects your previous console command
    programs.thefuck.enable = true;

    # Setting fish as our default shell causes some issues. Instead, automatically launch fish
    # when we start an interactive bash shell, but only if we're not opening one from fish.
    programs.bash = {
        enable = true;
        initExtra = ''
            if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]; then
                shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
                exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
            fi
        '';
    };
}
