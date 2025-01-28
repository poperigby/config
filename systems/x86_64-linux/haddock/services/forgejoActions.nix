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
      git
      nix
      nodejs
    ];
    config = {
      Cmd = [ "bash" ];
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
      labels = [ "haddock:docker://localhost/${actionsImage.imageName}:latest" ];
      settings = {
        cache.enabled = true;
        network = "host";
      };
    };
  };

  systemd.services.gitea-runner-default = {
    preStart = "${actionsImage} | ${getExe config.virtualisation.podman.package} load";
    after = [ "podman.socket" ];
    serviceConfig = {
      DynamicUser = mkForce false;
      User = mkForce "forgejo_actions";
    };
  };

  virtualisation.podman.enable = true;

  users = {
    users.forgejo_actions = {
      isSystemUser = true;
      group = "forgejo_actions";
      # The runner needs permission to access the Podman socket
      extraGroups = [ "podman" ];
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
