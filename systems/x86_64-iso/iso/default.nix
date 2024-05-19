{ pkgs, inputs, ... }:

{
    # Set the hostname
    networking.hostName = "iso";

    # Set password for root user
    # users.users.nixos.password = "nixos"; # TODO: Should this be an actual good password?

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
        networkmanager
        inputs.disko.packages.${pkgs.system}.disko
        poperigby.installer
    ];

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
