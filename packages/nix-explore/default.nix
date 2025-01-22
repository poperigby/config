{
  lib,
  pkgs,
  writeShellScriptBin,
  ...
}:

let
  inherit (lib)
    getExe
    ;

  yazi = getExe pkgs.yazi;
  nix = getExe pkgs.nix;
in

writeShellScriptBin "nix-explore" ''
  # Ensure a package name is provided as an argument
  if [ -z "$1" ]; then
    echo "Usage: nix-explore <nix-package>"
    exit 1
  fi

  package=$1

  ${yazi} $(${nix} eval --raw "$1".outPath)
''
