{ pkgs, ... }:

{
    poperigby = {};

    programs = {
        eza.enable = true;
        fzf.enable = true;
        # Let Home Manager install and manage itself
        home-manager.enable = true;
        # Integrates nix-index with command-not-found helper
        nix-index.enable = true;
    };

    # Programs that don't require any configuration
    home.packages = with pkgs; [
        asciinema
        fd
        just
        lazygit
        ouch
        ripgrep
        sops
        vimv-rs
        inputs.nh.packages."${pkgs.system}".nh
    ];

    # Make programs use XDG directories whenever supported
    home.preferXdgDirectories = true;

    # Nicely reload system units when changing configurations
    systemd.user.startServices = "sd-switch";
}
