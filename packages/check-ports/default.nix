{
  lib,
  pkgs,
  ...
}:

lib.custom.createShellScript {
  inherit pkgs;

  pname = "check-ports";
  src = ./script.sh;
  deps = with pkgs; [
    gawk
    iproute2
  ];
}
