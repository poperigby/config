{ pkgs, inputs, ... }:

{
    # Set the hostname
    networking.hostName = "iso";

    # Set password for root user
    users.users.nixos.password = "nixos"; # TODO: Should this be an actual good password?

    # Setup neovim
    programs.neovim = {
        enable = true;
        defaultEditor = true;
    };

    # Enable New CLI and Flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Useful packages for installation and recovery
    environment.systemPackages = with pkgs; [
        git
        gum
        networkmanager
        rsync
        inputs.disko.packages.${pkgs.system}.disko
        (writeShellScriptBin "installer" (builtins.readFile ./installer.sh))
    ];

    # DO NOT TOUCH 💀
    system.stateVersion = "23.11";
}
