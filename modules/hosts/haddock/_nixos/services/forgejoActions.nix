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
    services.gitea-actions-runner = {
        package = pkgs.forgejo-runner;
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
