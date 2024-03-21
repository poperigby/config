{ pkgs, ... }:

{
    # Set the hostname
    networking.hostName = "iso";

    # Setup the root password
    users.users.root.password = "nixos";

    # Set neovim as my default editor
    environment.variables.EDITOR = "nvim";

    environment.systemPackages = with pkgs; [
       neovim
    ];
}
