{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib)
        concatMapStringsSep
        getExe
        mkEnableOption
        mkIf
        mkOption
        mkPackageOption
        ;

    inherit (lib.types)
        bool
        enum
        listOf
        nullOr
        str
        submodule
        ;

    cfg = config.custom.security.opkssh;
in
{
    options.custom.security.opkssh = {
        enable = mkEnableOption "opkssh";
        package = mkPackageOption pkgs "opkssh" { };
        providers = mkOption {
            type = listOf (submodule {
                options = {
                    issuer = mkOption {
                        type = str;
                        description = "The issuer URI of the OpenID Provider.";
                        example = "https://accounts.google.com";
                    };
                    clientId = mkOption {
                        type = str;
                        description = "The Client ID (audience) for the OIDC provider.";
                        example = "206584157355-7cbe4s640tvm7naoludob4ut1emii7sf.apps.googleusercontent.com";
                    };
                    expiration = mkOption {
                        type = enum [
                            "12h"
                            "24h"
                            "48h"
                            "1week"
                            "oidc"
                            "oidc-refreshed"
                        ];
                        default = "24h";
                        description = ''
                            Expiration policy for user's SSH key.
                            Options: 12h, 24h, 48h, 1week, oidc, oidc-refreshed.
                        '';
                    };
                };
            });
            default = [
                {
                    issuer = "https://accounts.google.com";
                    clientId = "206584157355-7cbe4s640tvm7naoludob4ut1emii7sf.apps.googleusercontent.com";
                    expiration = "24h";
                }
                {
                    issuer = "https://login.microsoftonline.com/9188040d-6c67-4c5b-b112-36a304b66dad/v2.0";
                    clientId = "096ce0a3-5e72-4da8-9c86-12924b294a01";
                    expiration = "24h";
                }
            ];
            description = ''
                List of OpenID Providers allowed for opkssh access control.

                See the [documentation](https://github.com/openpubkey/opkssh/blob/main/README.md#etcopkproviders)
            '';
        };
        authorizedIdentities = mkOption {
            type = nullOr (
                listOf (submodule {
                    options = {
                        user = mkOption {
                            type = str;
                            description = "The account the user wants to assume.";
                            example = "alice";
                        };
                        identity = mkOption {
                            type = str;
                            description = ''
                                Email address, subject ID, or group identifier.
                                Group identifiers should use the form: oidc:groups:<groupId>
                            '';
                            example = "alice@example.com";
                        };
                        issuer = mkOption {
                            type = str;
                            description = "OIDC issuer URL";
                            example = "https://accounts.google.com";
                        };
                    };
                })
            );
            description = ''
                The global authorized identities file. This is a server wide file where policies
                can be configured to determine which identities can assume which Linux user accounts.

                See the [documentation](https://github.com/openpubkey/opkssh/blob/main/README.md#etcopkauth_id)
            '';
            example = {
                user = "alice";
                identity = "alice@example.com";
                issuer = "https://accounts.google.com";
            };
        };
        homePolicy = mkOption {
            type = bool;
            default = true;
            description = ''
                Configure a sudoer command so that the opkssh AuthorizedKeysCommand process can
                call out to the shell to run opkssh readhome {USER} and thereby read the policy
                file for the user in /home/{USER}/.opk/auth_id.
            '';
        };
    };

    config = mkIf cfg.enable {
        users = {
            users.opksshuser = {
                isSystemUser = true;
                group = "opksshuser";
            };
            groups.opksshuser = { };
        };

        services.openssh = {
            authorizedKeysCommand = "/run/wrappers/bin/opkssh verify %u %k %t";
            authorizedKeysCommandUser = "opksshuser";
        };

        security = {
            sudo.extraRules = mkIf cfg.homePolicy [
                {
                    users = [ "opksshuser" ];
                    commands = [
                        {
                            command = "${getExe cfg.package} readhome *";
                            options = [ "NOPASSWD" ];
                        }
                    ];
                }
            ];
            wrappers.opkssh = {
                source = getExe cfg.package;
                owner = "root";
                group = "root";
            };
        };

        environment = {
            etc = {
                "opk/providers" = {
                    text = concatMapStringsSep "\n" (
                        entry: "${entry.issuer} ${entry.clientId} ${entry.expiration}"
                    ) cfg.providers;
                    mode = "0640";
                    group = "opksshuser";
                };
                "opk/auth_id" = {
                    text = mkIf (cfg.authorizedIdentities != null) (
                        concatMapStringsSep "\n" (
                            entry: "${entry.user} ${entry.identity} ${entry.issuer}"
                        ) cfg.authorizedIdentities
                    );
                    mode = "0640";
                    group = "opksshuser";
                };
            };
        };
    };
}
