{ config, inputs, lib, pkgs, ... }:

let
    cfg = config.poperigby.suites.common;
in
{
    options.poperigby.suites.common.enable = lib.mkEnableOption "Enable common settings";

    imports = [
        inputs.nix-colors.homeManagerModules.default
    ];

    config = lib.mkIf cfg.enable {
        poperigby.programs = {
            bat.enable = true;
            bottom.enable = true;
            fish.enable = true;
            fzf.enable = true;
            git.enable = true;
            neovim.enable = true;
            tealdeer.enable = true;
            yazi.enable = true;
        };
        programs = {
            eza.enable = true;
            # Let Home Manager install and manage itself
            home-manager.enable = true;
            # Integrates nix-index with command-not-found helper
            nix-index.enable = true;
        };

        # Programs that don't require any configuration
        home.packages = with pkgs; [
            asciinema
            caligula
            fd
            just
            lazygit
            nh
            ouch
            ripgrep
            sops
            vimv-rs
        ];

        colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;

        home.pointerCursor = {
            name = "Adwaita";
            package = pkgs.gnome.adwaita-icon-theme;
            size = 24;
            x11.enable = true;
            gtk.enable = true;
        };

        # Make programs use XDG directories whenever supported
        home.preferXdgDirectories = true;

        # Nicely reload system units when changing configurations
        systemd.user.startServices = "sd-switch";
    };
}
