{
  config,
  lib,
  inputs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.custom.desktops.cosmic;
in
{
  imports = [ inputs.cosmic.nixosModules.default ];

  options.custom.desktops.cosmic = {
    enable = mkEnableOption "COSMIC Desktop";
  };

  config = mkIf cfg.enable {
    services = {
      desktopManager.cosmic.enable = true;
      displayManager.cosmic-greeter.enable = true;
    };

    nix.settings = {
      substituters = [ "https://cosmic.cachix.org/" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    };
  };
}
