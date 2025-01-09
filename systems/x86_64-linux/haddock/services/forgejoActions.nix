{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;
    instances.default = {
      enable = true;
      name = config.networking.hostName;
      url = "https://codeberg.org";
      tokenFile = config.sops.templates.forgejo-actions-codeberg-token.path;
      labels = [ "ubuntu-latest:docker" ];
    };
  };

  systemd.services.gitea-runner-default.serviceConfig =
    let
      inherit (lib) mkForce;
    in
    {
      DynamicUser = mkForce false;
      User = mkForce "forgejo_actions";
    };

  virtualisation.podman = {
    enable = true;
  };

  users = {
    users.forgejo_actions = {
      isSystemUser = true;
      group = "forgejo_actions";
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
