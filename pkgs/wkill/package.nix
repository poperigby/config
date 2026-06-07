{
    pkgs,
    ...
}:

pkgs.writeShellApplication {
    name = "wkill";
    runtimeInputs = with pkgs; [
        jq
        niri
    ];
    text = builtins.readFile ./script.sh;
}
