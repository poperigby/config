# DO-NOT-EDIT. This file was auto-generated using github:denful/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    den.url = "github:vic/den";
    direnv-instant.url = "github:Mic92/direnv-instant";
    disko.url = "github:nix-community/disko";
    erosanix = {
      url = "github:emmanuelrosa/erosanix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ledger-bot = {
      url = "github:poperigby/ledger-bot";
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
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    noctalia.url = "github:noctalia-dev/noctalia";
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
    piggyback = {
      url = "git+https://codeberg.org/PopeRigby/piggyback.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    private-config = {
      url = "git+ssh://git@codeberg.org/PopeRigby/private-config.git?ref=trunk";
      inputs.sops-nix.follows = "sops-nix";
    };
    proton-cachyos = {
      url = "github:Daaboulex/proton-cachyos-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ucodenix.url = "github:e-tho/ucodenix";
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
  };
}
