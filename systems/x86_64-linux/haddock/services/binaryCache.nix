{
    config,
    lib,
    pkgs,
    ...
}:

let
    cfg = config.services.nix-serve;
in
{
    services = {
        nix-serve = {
            enable = true;
            package = pkgs.nix-serve-ng;
            secretKeyFile = config.sops.secrets."haddock/binary_cache/secret_key".path;
        };
        caddy.virtualHosts."cache.haddock.cc".extraConfig = ''
            reverse_proxy :${toString cfg.port}
        '';
    };

    users = {
        groups.nix-serve = { };
        users.nix-serve = {
            isSystemUser = true;
            group = "nix-serve";
        };
    };

    systemd.services.nix-serve.serviceConfig.DynamicUser = lib.mkForce false;

    sops.secrets."haddock/binary_cache/secret_key".owner = "nix-serve";
}
