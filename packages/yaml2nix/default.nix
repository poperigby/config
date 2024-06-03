{
    alejandra,
    bat,
    pkgs,
    writeShellScriptBin,
    ...
}:

# TODO: Allow reading from STDIN

writeShellScriptBin "yaml2nix" ''
nix eval --impure --expr "builtins.fromYAML (builtins.readFile $(${pkgs.poperigby.file-path}/bin/file-path $1))" \
    | ${alejandra}/bin/alejandra --quiet \
    | ${bat}/bin/bat --language nix
''
