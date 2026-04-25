{
    lib,
    pkgs,
    ...
}:

lib.custom.createShellScript {
    inherit pkgs;

    pname = "screenshot";
    src = ./script.sh;
    deps = with pkgs; [
        grim
        jq
        libnotify
        slurp
        sway
        xdg-user-dirs
    ];
}
