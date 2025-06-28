{ lib, pkgs, ... }:

lib.custom.createShellScript {
  inherit pkgs;

  pname = "cliphist-rofi-img";
  src = ./script.sh;
  deps = [ pkgs.cliphist ];
}
