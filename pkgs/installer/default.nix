{ lib, pkgs, ... }:

lib.custom.createShellScript {
    inherit pkgs;

    pname = "installer";
    src = ./script.sh;
    deps = with pkgs; [
        disko
        git
        gum
        sops
    ];
}
