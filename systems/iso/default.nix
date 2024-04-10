{ pkgs, inputs, ... }:

{
    # Set the hostname
    networking.hostName = "iso";

    # Set password for root user
    users.users.nixos.password = "nixos"; # TODO: Should this be an actual good password?

    # Set neovim as my default editor
    environment.variables.EDITOR = "nvim";

    # Enable New CLI and Flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Useful packages for installation and recovery
    environment.systemPackages = with pkgs; [
        git
        gum
        neovim
        networkmanager
        rsync
        inputs.disko.packages.${pkgs.system}.disko
        (writeShellScriptBin "installer" (builtins.readFile ./installer.sh))
    ];
}
