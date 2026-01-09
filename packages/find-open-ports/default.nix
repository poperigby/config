{
    lib,
    pkgs,
    ...
}:

lib.custom.createShellScript {
    inherit pkgs;

    pname = "find-open-ports";
    src = ./script.sh;
    deps = with pkgs; [
        gawk
        iproute2
    ];
}
