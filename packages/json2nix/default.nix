{
    alejandra,
    bat,
    pkgs,
    writeShellScriptBin,
    ...
}:

# TODO: Allow reading from STDIN

writeShellScriptBin "json2nix" ''
nix eval --impure --expr "builtins.fromJSON (builtins.readFile $(${pkgs.poperigby.file-path}/bin/file-path $1))" \
    | ${alejandra}/bin/alejandra --quiet \
    | ${bat}/bin/bat --language nix
''
