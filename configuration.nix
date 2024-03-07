# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "haddock"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };



  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.cassidy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable 'sudo' for the user.
  };

  environment.systemPackages = with pkgs; [
    git
    neovim
    just
    podman
    inputs.nh.packages."${pkgs.system}".default
  ];


  # List services that you want to enable:
  services.openssh.enable = true;

  # Reverse SSH tunnel for SSHing into VM from host
  #systemd.services."reverse-ssh-tunnel" = {
  #  description = "Reverse SSH tunnel to allow connecting to VM via host";
  #  after = ["network.target"];
  #  wantedBy = ["multi-user.target"];
  #  serviceConfig = {
  #    Type = "simple";
  #    ExecStart = "${pkgs.openssh}/bin/ssh -NT -R 2222:localhost:22 cassidy@10.135.10.46";
  #  };
  #};

  # Limit the number of generations to keep
  boot.loader.systemd-boot.configurationLimit = 10;

  # Perform garbage collection weekly to maintain low disk usage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  # Optimize storage
  # You can also manually optimize the store via:
  #    nix-store --optimise
  # Refer to the following link for more details:
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

  # DO NOT TOUCH
  system.stateVersion = "23.11";
}
