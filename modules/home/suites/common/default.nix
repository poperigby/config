{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    getExe
    ;

  cfg = config.custom.suites.common;
in
{
  options.custom.suites.common.enable = mkEnableOption "settings that most homes will want enabled";

  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.nix-index-database.homeModules.nix-index
  ];

  config = mkIf cfg.enable {
    custom = {
      fonts.enable = true;
      nix.enable = true;
      programs = {
        atuin.enable = true;
        bat.enable = true;
        bottom.enable = true;
        fish.enable = true;
        git.enable = true;
        gpg.enable = true;
        neovim.enable = true;
        starship.enable = true;
        tealdeer.enable = true;
        television.enable = true;
        yazi = {
          enable = true;
          default = true;
        };
      };
      security = {
        secrets.enable = true;
        opkssh = {
          enable = true;
          settings = {
            default_provider = "authelia";
            providers = [
              {
                alias = "authelia";
                issuer = "https://auth.haddock.cc";
                client_id = "opkssh";
                scopes = "openid offline_access";
                access_type = "offline";
                prompt = "consent";
                redirect_uris = [
                  "http://localhost:3000/login-callback"
                  "http://localhost:10001/login-callback"
                  "http://localhost:11110/login-callback"
                ];
              }
            ];
          };
        };
      };
    };
    programs = {
      eza.enable = true;
      direnv.enable = true;
      # Let Home Manager install and manage itself
      home-manager.enable = true;
      # Integrates nix-index with command-not-found helper
      nix-index.enable = true;
      nix-index-database.comma.enable = true;
      pay-respects.enable = true;
      zoxide = {
        enable = true;
        options = [
          "--cmd cd"
        ];
      };
    };

    home = {
      # Programs that don't require any configuration
      packages = with pkgs; [
        asciinema
        binsider
        caligula
        delta
        dmidecode
        dogdns
        dust
        fd
        ffmpeg
        file
        imagemagick
        jq
        just
        lazygit
        nix-init
        nixfmt-rfc-style
        nurl
        ouch
        parted
        pciutils
        ripgrep
        sops
        systemctl-tui
        tree
        typst
        usbutils
        vimv-rs
        xh
      ];
      # Handy aliases
      shellAliases = {
        cat = "bat";
        find = "fd";
        grep = "rg";
        jrn = "sudo journalctl";
        license = getExe pkgs.license-generator;
        nps = "nix search nixpkgs";
        py = "python";
        sys = "sudo systemctl";
        syu = "systemctl --user";
        yt = getExe pkgs.yt-dlp;
      };
    };

    colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
  };
}
