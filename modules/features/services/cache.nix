{ den, ... }:

{
    den.aspects.services.provides.cache.nixos =
        {
            config,
            lib,
            pkgs,
            ...
        }:
        let
            endpoint = "https://cache.haddock.cc";
            cache = "haddock";
            publicKey = "haddock:KOMEs2nk2hrAD2nwiUUVUH5Sad5DY2/FEAcbzVcxBqY=";
            tokenFile = config.sops.secrets."common/attic/token".path;
            clientConfig = pkgs.writeTextDir "attic/config.toml" ''
                default-server = "haddock"

                [servers.haddock]
                endpoint = "${endpoint}"
                token-file = "${tokenFile}"
            '';
        in
        {
            environment.systemPackages = [ pkgs.attic-client ];

            nix.settings = {
                substituters = [ "${endpoint}/${cache}" ];
                trusted-public-keys = [ publicKey ];
                netrc-file = config.sops.templates."attic-netrc".path;
            };

            systemd.services.attic-watch-store = {
                description = "Upload new Nix store paths to the Haddock cache";
                wantedBy = [ "multi-user.target" ];
                after = [ "network-online.target" ];
                wants = [ "network-online.target" ];
                # attic holds a lock on the local store, which blocks the daemon when a
                # new Nix version needs exclusive access to upgrade the store database.
                restartTriggers = [ config.nix.package ];
                environment.XDG_CONFIG_HOME = clientConfig;
                serviceConfig = {
                    ExecStart = "${lib.getExe pkgs.attic-client} watch-store haddock:${cache}";
                    Restart = "on-failure";
                    RestartSec = "10s";
                };
            };

            sops = {
                secrets."common/attic/token" = {
                    restartUnits = [ "attic-watch-store.service" ];
                };
                templates."attic-netrc" = {
                    content = ''
                        machine cache.haddock.cc
                        password ${config.sops.placeholder."common/attic/token"}
                    '';
                    mode = "0400";
                    restartUnits = [ "nix-daemon.service" ];
                };
            };
        };
}
