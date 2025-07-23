{ pkgs, ... }:

{
  imports = [
    ./drives.nix
    ./hardware.nix
    ./services
  ];

  custom = {
    services = {
      backups = {
        enable = true;
        # Backup to Tintin as well as BorgBase
        repositories.tintin = true;
        paths = [
          "/var/lib/bazarr"
          "/var/lib/immich"
          "/var/lib/jellyfin"
          "/var/lib/karakeep"
          "/var/lib/lldap"
          "/var/lib/mealie"
          "/var/lib/minecraft/*/world"
          "/var/lib/moonfire-nvr"
          "/var/lib/paperless"
          "/var/lib/private/prowlarr"
          "/var/lib/radarr"
          "/var/lib/readarr"
          "/var/lib/rustical"
          "/var/lib/silverbullet"
          "/var/lib/sonarr"
          "/var/lib/vikunja"
        ];
      };
      postfix.enable = true;
    };
    suites = {
      common.enable = true;
    };
    security.opkssh = {
      enable = true;
      providers = [
        {
          issuer = "https://auth.haddock.cc";
          clientId = "opkssh";
          expiration = "oidc";
        }
      ];
      authorizedIdentities = [
        {
          user = "cassidy";
          identity = "cb283dd6-3e06-459f-81ac-76afcf0cfa6b";
          issuer = "https://auth.haddock.cc";
        }
      ];
    };
    users = {
      cassidy.enable = true;
      julian.enable = true;
      shane.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    lynis
  ];

  time.timeZone = "America/Los_Angeles";

  services.openssh = {
    enable = true;
    settings = {
      # https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-20-04
      PermitRootLogin = "no";
      MaxAuthTries = 3;
      PasswordAuthentication = false;
      PermitEmptyPasswords = false;
      ChallengeResponseAuthentication = false;
      PermitUserEnvironment = false;
      AllowAgentForwarding = false;
      AllowTcpForwarding = false;
      PermitTunnel = false;
    };
  };

  networking.useDHCP = true;

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
