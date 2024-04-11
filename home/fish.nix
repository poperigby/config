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
                    rev = "v1.19.2";
                    sha256 = "";
                };
            }
        ];
        shellAliases = {
            cat = "bat";
            grep = "rg";
            jrn = "sudo journalctl";
            lg = "lazygit";
            ls = "eza";
            py = "python";
            sys = "sudo systemctl";
            syu = "systemctl --user";
        };
    };
}
