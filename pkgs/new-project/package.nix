{
    pkgs,
    ...
}:

pkgs.writeShellApplication {
    name = "new-project";

    runtimeInputs = with pkgs; [
        cargo
        direnv
        gum."0.17.0"
        jujutsu
        nix
    ];

    text = builtins.replaceStrings [ "@template_source@" ] [ (toString ../..) ] (
        builtins.readFile ./script.sh
    );
}
