{
    lib,
    pkgs,
    ...
}:

lib.custom.createShellScript {
    inherit pkgs;

    pname = "wkill";
    src = ./script.sh;
    deps = with pkgs; [
        jq
        niri
    ];
}
