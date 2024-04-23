{ inputs, ... }:

{
    imports = [
        inputs.nix-index-database.hmModules.nix-index
        ./gaming
        ./gui
        ./programs
        ./shell
    ];

    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    home = {
        username = "cassidy";
        homeDirectory = "/home/cassidy";
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    # Nicely reload system units when changing configurations
    systemd.user.startServices = "sd-switch";

    # Enable nix-index and integrate with command-not-found helper
    programs.nix-index.enable = true;

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home.stateVersion = "23.11";
}
