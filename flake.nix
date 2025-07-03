{
  description = "My NixOS flake";

  # Inputs for building the NixOS system, such as software repositories.
  inputs = {
    ## Official inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ## Extra inputs
    crowdsec = {
      url = "git+https://codeberg.org/kampka/nix-flake-crowdsec.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flux = {
      url = "github:IogaMaster/flux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix = {
      url = "github:NixOS/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord.url = "github:kaylorben/nixcord";
    nix-colors.url = "github:misterio77/nix-colors";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";
    openmw-nix = {
      url = "git+https://codeberg.org/PopeRigby/openmw-nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ucodenix.url = "github:e-tho/ucodenix";
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
    # Temporary inputs for unmerged PRs
    qbittorrent.url = "github:fsnkty/nixpkgs/init-nixos-qbittorrent";
  };

  # This function is run on `nixos-rebuild switch`, and generates NixOS systems
  # based on the `inputs` attribute set, and any `modules` specified.
  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;

      # Where my source files are located
      src = ./.;

      # A namespace to use for my flake's packages, library, and overlays.
      snowfall.namespace = "custom";

      channels-config.allowUnfree = true;

      systems = {
        # Host specific options
        hosts = {
          # Home server
          haddock = {
            modules = with inputs; [
              crowdsec.nixosModules.crowdsec
              crowdsec.nixosModules.crowdsec-firewall-bouncer
              flux.nixosModules.default
              nix-minecraft.nixosModules.minecraft-servers
              vpn-confinement.nixosModules.default
              "${qbittorrent}/nixos/modules/services/torrent/qbittorrent.nix"
            ];
          };
          # Desktop
          snowy = { };
          # Laptop
          allan = {
            modules = with inputs; [
              nixos-hardware.nixosModules.framework-11th-gen-intel
            ];
          };
          # Installation/recovery ISO
          skut = {
            modules = with inputs; [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ];
          };
          # 3D printer
          # nestor = {
          #   modules = with inputs; [
          #     nixos-raspberrypi.lib.inject-overlays
          #     nixos-raspberrypi.nixosModules.raspberry-pi-02.base
          #     nixos-raspberrypi.nixosModules.trusted-nix-caches
          #   ];
          # };
        };
        # Modules that get imported to every NixOS system
        modules.nixos = with inputs; [
          disko.nixosModules.disko
          ucodenix.nixosModules.ucodenix
        ];
      };
      homes = {
        # Modules that get imported to every home
        modules = with inputs; [
          nix-colors.homeManagerModules.default
          nixcord.homeModules.nixcord
        ];
      };
    };
}
