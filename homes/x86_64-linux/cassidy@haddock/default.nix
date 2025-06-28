{ pkgs, ... }:

{
  custom = {
    suites = {
      common.enable = true;
    };
  };

  # For CrowdSec
  programs.fish.shellAliases.cs = "sudo cscli";

  home.packages = with pkgs; [
    custom.check-ports
  ];
}
