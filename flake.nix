# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    den.url = "github:vic/den";
    disko.url = "github:nix-community/disko";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flux = {
      url = "github:IogaMaster/flux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hushmic.url = "github:crowquillx/hushmic-nix";
    import-tree.url = "github:vic/import-tree";
    jj-starship.url = "github:dmmulroy/jj-starship";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix = {
      url = "github:NixOS/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord.url = "github:kaylorben/nixcord";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/nixos-unstable";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    nixpkgs-multiverse.url = "github:fzakaria/nixpkgs-multiverse";
    nixpkgs-patch-crowdsec-10-core = {
      url = "https://github.com/NixOS/nixpkgs/compare/10b3b48b25f0e71e900acfce5892014029bc6bfb...382c503f7237dad92d3be8cf966c695141c92ed0.diff";
      flake = false;
    };
    nixpkgs-patch-crowdsec-20-default-text = {
      url = "https://github.com/NixOS/nixpkgs/commit/196e02c147d558a86f881f85f338c1063f14c6cb.diff";
      flake = false;
    };
    nixpkgs-patch-millennium = {
      url = "https://github.com/NixOS/nixpkgs/pull/538226.diff";
      flake = false;
    };
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    noctalia.url = "github:noctalia-dev/noctalia";
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
    openmw-nix = {
      url = "git+https://codeberg.org/PopeRigby/openmw-nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    piggyback = {
      url = "git+https://codeberg.org/PopeRigby/piggyback.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    private-config.url = "git+ssh://git@codeberg.org/PopeRigby/private-config.git?ref=trunk";
    proton-cachyos = {
      url = "github:Daaboulex/proton-cachyos-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ucodenix.url = "github:e-tho/ucodenix";
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
  };
}
