{
    config,
    lib,
    pkgs,
    inputs,
    ...
}:

let
    inherit (lib) mkForce getExe;

    buildImageWithNix = pkgs.callPackage "${inputs.nix}/docker.nix";
    actionsImage = buildImageWithNix {
        inherit pkgs;

        name = "actions-image";
        tag = "latest";
        nixConf.experimental-features = "nix-command flakes";
        extraPkgs = with pkgs; [
            jq
            nix-update
            nodejs
        ];
    };
in
{
    services.forgejo-runner = {
        instances.default = {
            enable = true;
            runtimes.docker = true;
            secrets.server.connections.default.token_url =
                config.sops.secrets."haddock/forgejo_actions/tokens/codeberg".path;
            settings = {
                server.connections.default = {
                    url = "https://codeberg.org";
                    uuid = "9ed8a7d3-02b8-4c0c-b309-402fef28baf9";
                    token = null;
                };
                runner.labels = [ "haddock:docker://${actionsImage.imageName}:latest" ];
                cache.enabled = true;
                container.network = "host";
            };
        };
    };

    systemd.services.forgejo-runner-default = {
        preStart = "${getExe config.virtualisation.docker.package} load < ${actionsImage}";
        after = [ "docker.service" ];
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

    sops.secrets."haddock/forgejo_actions/tokens/codeberg".owner = "forgejo_actions";
}
