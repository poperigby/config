# Wire local custom packages into `pkgs.custom.*` for both NixOS and Home Manager.
{ den, ... }:
let
  overlay =
    final: prev:
    {
      lib = prev.lib // {
        custom = import ../lib/create-shell-script { lib = prev.lib; };
      };

      custom = {
        cliphist-rofi-img = final.callPackage ../packages/cliphist-rofi-img { };
        find-my-device-server = final.callPackage ../packages/find-my-device-server { };
        find-open-ports = final.callPackage ../packages/find-open-ports { };
        grabweather = final.callPackage ../packages/grabweather { };
        illuminanced = final.callPackage ../packages/illuminanced { };
        installer = final.callPackage ../packages/installer { };
        loot = final.callPackage ../packages/loot/package.nix { };
        qbittorrent-vpn-port-update = final.callPackage ../packages/qbittorrent-vpn-port-update { };
        reef = final.callPackage ../packages/reef { };
        rofi-wifi = final.callPackage ../packages/rofi-wifi { };
        screenshot = final.callPackage ../packages/screenshot { };
        valve-file-vdf = final.callPackage ../packages/valve-file-vdf { };
      };
    };
in
{
  den.default = {
    nixos.nixpkgs.overlays = [ overlay ];
    homeManager.nixpkgs.overlays = [ overlay ];
  };
}
