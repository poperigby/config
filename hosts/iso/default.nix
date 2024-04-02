{ pkgs, inputs, ... }:

{
    # Set the hostname
    networking.hostName = "iso";

    # Set password for nixos user
    users.users.nixos.password = "nixos";

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
        inputs.disko.packages.${pkgs.system}.disko
        (writeShellScriptBin "installer" (builtins.readFile ./installer.sh))
    ];
}
