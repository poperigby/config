{ pkgs, ... }:

pkgs.writeShellApplication {
    name = "installer";
    runtimeInputs = with pkgs; [
        disko
        git
        gum
        sops
    ];
    text = builtins.readFile ./script.sh;
}
