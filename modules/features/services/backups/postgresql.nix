{ ... }:

{
    den.aspects.services.provides.backup.postgresql =
        {
            databases ? null,
            excludeDatabases ? [ ],
            ...
        }:
        {
            nixos =
                {
                    config,
                    lib,
                    pkgs,
                    ...
                }:
                let
                    inherit (lib)
                        escapeShellArg
                        getExe
                        getExe'
                        mkIf
                        optionalString
                        ;

                    name = "borgbase";
                    hostName = config.networking.hostName;
                    enabled = if databases == null then config.services.postgresql.enable else databases;
                    restic = lib.getExe config.services.restic.backups.${name}.package;
                    backupEnv = config.systemd.services."restic-backups-${name}".environment;
                    postgres = config.services.postgresql.finalPackage;
                in
                mkIf enabled {
                    systemd.services = {
                        "restic-backups-${name}-db" = {
                            description = "PostgreSQL Restic backup for ${name}";
                            environment = {
                                RESTIC_CACHE_DIR = backupEnv.RESTIC_CACHE_DIR;
                                RESTIC_PASSWORD_FILE = backupEnv.RESTIC_PASSWORD_FILE;
                                RESTIC_REPOSITORY_FILE = backupEnv.RESTIC_REPOSITORY_FILE;
                            };
                            serviceConfig = {
                                Type = "oneshot";
                                ExecStart = getExe (
                                    pkgs.writeShellScriptBin "database-backup" ''
                                        set -euo pipefail
                                        ${restic} backup \
                                          --tag database \
                                          --stdin-filename all.sql \
                                          --stdin-from-command -- \
                                          ${getExe' postgres "pg_dumpall"} --clean --if-exists ${
                                              lib.concatMapStringsSep " " (
                                                  database: escapeShellArg "--exclude-database=${database}"
                                              ) excludeDatabases
                                          }
                                    ''
                                );
                            };
                        };

                        "restic-restore-test-db-${name}" = {
                            description = "Restore the ${name} PostgreSQL backup into an isolated cluster";
                            unitConfig.OnFailure = "notify-backup-failure@%n.service";
                            serviceConfig = {
                                Type = "oneshot";
                                DynamicUser = true;
                                RuntimeDirectory = "restic-restore-test-db-${name}";
                                RuntimeDirectoryMode = "0700";
                                LoadCredential = [
                                    "restic-password:${config.sops.secrets."${hostName}/restic/${name}/password".path}"
                                    "restic-repository:${config.sops.secrets."${hostName}/restic/${name}/url".path}"
                                ];
                                PrivateTmp = true;
                                ProtectHome = true;
                                ProtectSystem = "strict";
                                ExecStart =
                                    let
                                        preloadLibraries = config.services.postgresql.settings.shared_preload_libraries or null;
                                        preloadOptions = optionalString (preloadLibraries != null && preloadLibraries != "") (
                                            "-o " + escapeShellArg "-c shared_preload_libraries=${preloadLibraries}"
                                        );
                                    in
                                    getExe (
                                        pkgs.writeShellApplication {
                                            name = "restic-restore-test-db-${name}";
                                            runtimeInputs = with pkgs; [
                                                (ephemeralpg.override { postgresql = postgres; })
                                                gawk
                                                postgres
                                            ];
                                            text = ''
                                                export RESTIC_PASSWORD_FILE="$CREDENTIALS_DIRECTORY/restic-password"
                                                export RESTIC_REPOSITORY_FILE="$CREDENTIALS_DIRECTORY/restic-repository"

                                                cluster="$RUNTIME_DIRECTORY/cluster"
                                                database_url=$(pg_tmp -d "$cluster" -w 0 ${preloadOptions} start)

                                                cleanup() {
                                                  pg_tmp -d "$cluster" stop >/dev/null 2>&1 || true
                                                }

                                                trap cleanup EXIT

                                                ${restic} dump latest all.sql \
                                                  --tag database \
                                                  --retry-lock 1h \
                                                  --no-cache \
                                                  | psql --no-psqlrc --set=ON_ERROR_STOP=1 "$database_url"

                                                pg_dumpall --dbname="$database_url" >/dev/null
                                                printf 'Restored databases:\n'
                                                psql \
                                                  --no-psqlrc \
                                                  --tuples-only \
                                                  --no-align \
                                                  --command='SELECT datname FROM pg_database WHERE datallowconn ORDER BY datname' \
                                                  "$database_url"
                                                printf 'Isolated PostgreSQL restore test passed.\n'
                                            '';
                                        }
                                    );
                            };
                        };
                    };
                };
        };
}
