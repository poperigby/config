{
    config,
    lib,
    pkgs,
    ...
}:

let
    cfg = config.services.atticd;
    cacheName = "haddock";
    publicKey = "haddock:KOMEs2nk2hrAD2nwiUUVUH5Sad5DY2/FEAcbzVcxBqY=";
in

{
    services = {
        atticd = {
            enable = true;
            environmentFile = config.sops.templates."atticd-environment".path;
            settings = {
                listen = "[::1]:8080";
                allowed-hosts = [ "cache.haddock.cc" ];
                api-endpoint = "https://cache.haddock.cc/";
                database.url = "postgresql://atticd@localhost/atticd?host=%2Frun%2Fpostgresql";
                garbage-collection = {
                    interval = "12 hours";
                    default-retention-period = "6 months";
                };
            };
        };
        caddy.virtualHosts."cache.haddock.cc".extraConfig = ''
            reverse_proxy [::1]:8080
        '';
        postgresql = {
            ensureDatabases = [ "atticd" ];
            ensureUsers = [
                {
                    name = "atticd";
                    ensureDBOwnership = true;
                }
            ];
        };
    };

    systemd.services = {
        atticd = {
            after = [ "postgresql.target" ];
            requires = [ "postgresql.target" ];
        };
        atticd-provision = {
            description = "Provision the declarative Attic cache";
            wantedBy = [ "multi-user.target" ];
            after = [ "atticd.service" ];
            requires = [ "atticd.service" ];
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart =
                    let
                        endpoint = "http://[::1]:8080/_api/v1/cache-config/${cacheName}";
                        adminConfig = (pkgs.formats.toml { }).generate "atticd-provision.toml" cfg.settings;
                        provision = pkgs.writeShellApplication {
                            name = "atticd-provision";
                            runtimeInputs = with pkgs; [
                                curl
                                jq
                            ];
                            text = ''
                                endpoint=${lib.escapeShellArg endpoint}
                                response="$RUNTIME_DIRECTORY/response.json"
                                payload="$RUNTIME_DIRECTORY/payload.json"

                                for _ in {1..30}; do
                                  if curl --globoff --silent --output /dev/null --header 'Host: cache.haddock.cc' "http://[::1]:8080/"; then
                                    break
                                  fi
                                  sleep 1
                                done

                                token="$(${lib.getExe' cfg.package "atticadm"} \
                                  --config ${adminConfig} \
                                  make-token \
                                  --sub declarative-provisioner \
                                  --validity 5m \
                                  --pull ${cacheName} \
                                  --create-cache ${cacheName} \
                                  --configure-cache ${cacheName})"

                                jq --null-input \
                                  --rawfile keypair "$CREDENTIALS_DIRECTORY/cache-key" \
                                  '{
                                    keypair: { Keypair: ($keypair | rtrimstr("\\n")) },
                                    is_public: false,
                                    store_dir: "/nix/store",
                                    priority: 41,
                                    upstream_cache_key_names: ["cache.nixos.org-1"]
                                  }' >"$payload"

                                status="$(curl --globoff --silent --show-error \
                                  --output "$response" \
                                  --write-out '%{http_code}' \
                                  --header 'Host: cache.haddock.cc' \
                                  --header "Authorization: Bearer $token" \
                                  "$endpoint")"

                                case "$status" in
                                  200)
                                    method=PATCH
                                    action=Reconciled
                                    ;;
                                  404)
                                    method=POST
                                    action=Created
                                    ;;
                                  *)
                                    cat "$response" >&2
                                    echo "Unexpected response while checking Attic cache: HTTP $status" >&2
                                    exit 1
                                    ;;
                                esac

                                curl --globoff --fail-with-body --silent --show-error \
                                  --request "$method" \
                                  --header 'Host: cache.haddock.cc' \
                                  --header 'Content-Type: application/json' \
                                  --header "Authorization: Bearer $token" \
                                  --data-binary "@$payload" \
                                  "$endpoint"

                                echo "$action private Attic cache '${cacheName}'"

                                actual_public_key="$(curl --globoff --fail-with-body --silent --show-error \
                                  --header 'Host: cache.haddock.cc' \
                                  --header "Authorization: Bearer $token" \
                                  "$endpoint" | jq --raw-output '.public_key')"

                                if [[ "$actual_public_key" != ${lib.escapeShellArg publicKey} ]]; then
                                  echo "Attic public key does not match the declarative key" >&2
                                  exit 1
                                fi

                                echo "Verified Attic cache public key: $actual_public_key"
                            '';
                        };
                    in
                    lib.getExe provision;
                EnvironmentFile = cfg.environmentFile;
                LoadCredential = "cache-key:${config.sops.secrets."haddock/attic/cache_key".path}";
                RuntimeDirectory = "atticd-provision";
                RuntimeDirectoryMode = "0700";
            };
        };
        attic-watch-store = {
            after = [ "atticd-provision.service" ];
            requires = [ "atticd-provision.service" ];
        };
    };

    sops = {
        secrets = {
            "haddock/attic/jwt_secret" = { };
            "haddock/attic/cache_key".restartUnits = [ "atticd-provision.service" ];
        };
        templates."atticd-environment" = {
            content = ''
                ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64=${config.sops.placeholder."haddock/attic/jwt_secret"}
            '';
            restartUnits = [ "atticd.service" ];
        };
    };
}
