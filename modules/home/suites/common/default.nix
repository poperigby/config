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

  imports = [ inputs.nix-colors.homeManagerModules.default ];

  config = mkIf cfg.enable {
    custom = {
      accounts = {
        contacts.enable = true;
        email.enable = true;
      };
      fonts.enable = true;
      nix.enable = true;
      programs = {
        atuin.enable = true;
        bat.enable = true;
        bottom.enable = true;
        fish.enable = true;
        fzf.enable = true;
        git.enable = true;
        gpg.enable = true;
        neovim.enable = true;
        starship.enable = true;
        tealdeer.enable = true;
        yazi = {
          enable = true;
          default = true;
        };
      };
      security.secrets.enable = true;
    };
    programs = {
      eza.enable = true;
      direnv.enable = true;
      # Let Home Manager install and manage itself
      home-manager.enable = true;
      # Integrates nix-index with command-not-found helper
      nix-index.enable = true;
      thefuck.enable = true;
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
        custom.nix-explore
        dmidecode
        dogdns
        dust
        fd
        ffmpeg
        file
        imagemagick
        just
        lazygit
        nh
        nix-init
        nixfmt-rfc-style
        nurl
        ouch
        parted
        pciutils
        ripgrep
        sops
        tree
        typst
        usbutils
        vimv-rs
      ];
      # Handy aliases
      shellAliases = {
        cat = "bat";
        find = "fd";
        grep = "rg";
        jrn = "sudo journalctl";
        lg = "lazygit";
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
