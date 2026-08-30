{ pkgs, ... }:

pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = with pkgs; [
        grim
        libnotify
        satty
        slurp
        wl-clipboard
    ];
    text = builtins.readFile ./script.sh;
}
