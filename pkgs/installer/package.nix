{ pkgs, ... }:

pkgs.writeShellApplication {
    name = "installer";
    runtimeInputs = with pkgs; [
        age
        bitwarden-cli
        coreutils
        disko
        findutils
        git
        gnugrep
        gum
        jq
        sops
        sudo
    ];
    text = builtins.readFile ./script.sh;
}
