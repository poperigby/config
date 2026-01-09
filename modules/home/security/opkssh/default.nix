{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib)
        mkEnableOption
        mkIf
        mkOption
        mkPackageOption
        ;

    cfg = config.custom.security.opkssh;
    settingsFormat = pkgs.formats.yaml { };
in
{
    options.custom.security = {
        opkssh = {
            enable = mkEnableOption "Enable opkssh config for this user";
            package = mkPackageOption pkgs "opkssh" { };
            settings = mkOption {
                type = settingsFormat.type;
                default = {
                    default_provider = "webchooser";
                    providers = [
                        {
                            alias = [ "google" ];
                            issuer = "https://accounts.google.com";
                            client_id = "206584157355-7cbe4s640tvm7naoludob4ut1emii7sf.apps.googleusercontent.com";
                            client_secret = "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";
                            scopes = [
                                "openid"
                                "email"
                                "profile"
                            ];
                            access_type = "offline";
                            prompt = "consent";
                            redirect_uris = [
                                "http://localhost:3000/login-callback"
                                "http://localhost:10001/login-callback"
                                "http://localhost:11110/login-callback"
                            ];
                        }
                        {
                            alias = [
                                "azure"
                                "microsoft"
                            ];
                            issuer = "https://login.microsoftonline.com/9188040d-6c67-4c5b-b112-36a304b66dad/v2.0";
                            client_id = "096ce0a3-5e72-4da8-9c86-12924b294a01";
                            scopes = [
                                "openid"
                                "profile"
                                "email"
                                "offline_access"
                            ];
                            access_type = "offline";
                            prompt = "consent";
                            redirect_uris = [
                                "http://localhost:3000/login-callback"
                                "http://localhost:10001/login-callback"
                                "http://localhost:11110/login-callback"
                            ];
                        }
                        {
                            alias = [ "gitlab" ];
                            issuer = "https://gitlab.com";
                            client_id = "8d8b7024572c7fd501f64374dec6bba37096783dfcd792b3988104be08cb6923";
                            scopes = [
                                "openid"
                                "email"
                            ];
                            access_type = "offline";
                            prompt = "consent";
                            redirect_uris = [
                                "http://localhost:3000/login-callback"
                                "http://localhost:10001/login-callback"
                                "http://localhost:11110/login-callback"
                            ];
                        }
                        {
                            alias = [ "hello" ];
                            issuer = "https://issuer.hello.coop";
                            client_id = "app_xejobTKEsDNSRd5vofKB2iay_2rN";
                            scopes = [
                                "openid"
                                "email"
                            ];
                            access_type = "offline";
                            prompt = "consent";
                            redirect_uris = [
                                "http://localhost:3000/login-callback"
                                "http://localhost:10001/login-callback"
                                "http://localhost:11110/login-callback"
                            ];
                        }
                    ];
                };
                description = ''
                    Configuration for OPKSSH
                '';
            };
        };
    };

    config = mkIf config.custom.security.opkssh.enable {
        home = {
            packages = [ config.custom.security.opkssh.package ];
            file.".opk/config.yml".source = settingsFormat.generate "config.yml" cfg.settings;
        };
    };
}
