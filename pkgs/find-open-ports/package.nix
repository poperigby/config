{
    pkgs,
    ...
}:

pkgs.writeShellApplication {
    name = "find-open-ports";
    runtimeInputs = with pkgs; [
        gawk
        iproute2
    ];
    text = builtins.readFile ./script.sh;
}
