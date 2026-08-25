{ pkgs, ... }:

pkgs.writeShellApplication {
    name = "niri-maximize-if-alone";
    runtimeInputs = with pkgs; [
        jq
        niri
    ];
    text = builtins.readFile ./script.sh;
}
