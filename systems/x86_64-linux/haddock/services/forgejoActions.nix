{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkForce getExe;

  actionsImage = pkgs.dockerTools.streamLayeredImage {
    name = "actions-image";
    tag = "latest";
    contents = with pkgs; [
      bash
      cacert
      coreutils
      git
      nix
      nodejs
      openssl
      gnugrep
      less
    ];
    config = {
      Cmd = [ "bash" ];
      Env = [
        # So Git can find the required certificates
        "GIT_SSL_CAINFO=/etc/ssl/certs/ca-bundle.crt"
      ];
    };
  };
in
{
  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;
    instances.default = {
      enable = true;
      name = config.networking.hostName;
      url = "https://codeberg.org";
      tokenFile = config.sops.templates.forgejo-actions-codeberg-token.path;
      labels = [ "haddock:docker://${actionsImage.imageName}:latest" ];
      settings = {
        cache.enabled = true;
        network = "host";
      };
    };
  };

  systemd.services.gitea-runner-default = {
    preStart = "${actionsImage} | ${getExe config.virtualisation.docker.package} load";
    serviceConfig = {
      DynamicUser = mkForce false;
      User = mkForce "forgejo_actions";
    };
  };

  virtualisation.docker.enable = true;

  users = {
    users.forgejo_actions = {
      isSystemUser = true;
      group = "forgejo_actions";
      # The runner needs permission to access the Docker socket
      extraGroups = [ "docker" ];
    };
    groups.forgejo_actions = { };
  };

  sops = {
    templates.forgejo-actions-codeberg-token = {
      content = ''
        TOKEN=${config.sops.placeholder."haddock/forgejo_actions/tokens/codeberg"}
      '';
      owner = "forgejo_actions";
    };
    secrets."haddock/forgejo_actions/tokens/codeberg".owner = "forgejo_actions";
  };
}
