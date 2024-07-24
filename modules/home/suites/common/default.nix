# Settings that most homes will want enabled

{ config, inputs, lib, pkgs, ... }:

let
    cfg = config.poperigby.suites.common;
in
{
    options.poperigby.suites.common.enable = lib.mkEnableOption "settings that most homes will want enabled";

    imports = [ inputs.nix-colors.homeManagerModules.default ];

    config = lib.mkIf cfg.enable {
        poperigby = {
            # Font management
            fonts.enable = true;
            nix.enable = true;
            programs = {
                atuin.enable = true;
                bat.enable = true;
                bottom.enable = true;
                fish.enable = true;
                fzf.enable = true;
                git.enable = true;
                neovim.enable = true;
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
        };

        # Programs that don't require any configuration
        home.packages = with pkgs; [
            asciinema
            caligula
            dogdns
            dust
            fd
            imagemagick
            just
            lazygit
            nh
            ouch
            parted
            poperigby.json2nix
            ripgrep
            sops
            vimv-rs
        ];

        colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
    };
}
