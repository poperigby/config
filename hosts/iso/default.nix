{ pkgs, ... }:

{
    # Set the hostname
    networking.hostName = "iso";

    # Setup the root password
    users.users.root.password = "nixos";

    # Set neovim as my default editor
    environment.variables.EDITOR = "nvim";

    # Enable New CLI and Flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Useful packages for installation and recovery
    environment.systemPackages = with pkgs; [
       neovim
    ];
}
