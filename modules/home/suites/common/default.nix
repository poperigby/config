{ pkgs, ... }:

{
    programs = {
        eza.enable = true;
        fzf.enable = true;
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
}
