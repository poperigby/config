{ pkgs, ... }:

pkgs.writeShellApplication {
    name = "toml2nix";
    runtimeInputs = with pkgs; [
        coreutils
        nix
        nixfmt
    ];
    text = builtins.readFile ./script.sh;
}
