{ pkgs, ... }:

pkgs.writeShellApplication {
    name = "toml2nix";
    runtimeInputs = with pkgs; [
        coreutils
        nixfmt
        toml2nix
    ];
    text = builtins.readFile ./script.sh;
}
