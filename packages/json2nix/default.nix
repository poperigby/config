{
    alejandra,
    bat,
    writeShellScriptBin,
    ...
}:

# TODO: Allow reading from STDIN and absolute paths

writeShellScriptBin "json2nix" ''
nix eval --impure --expr "builtins.fromJSON (builtins.readFile $1)" | ${alejandra}/bin/alejandra --quiet | ${bat}/bin/bat --language nix
''
