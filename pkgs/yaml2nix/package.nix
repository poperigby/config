{ pkgs, ... }:

pkgs.writeShellApplication {
    name = "yaml2nix";
    runtimeInputs = with pkgs; [
        coreutils
        nixfmt
        yaml2nix
    ];
    text = builtins.readFile ./script.sh;
}
