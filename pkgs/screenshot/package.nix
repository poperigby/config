{ pkgs, ... }:

pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = with pkgs; [
        grim
        jq
        libnotify
        niri
        satty
        slurp
        wl-clipboard
    ];
    text = builtins.readFile ./script.sh;
}
