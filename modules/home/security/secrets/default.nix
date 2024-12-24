{ config, inputs, lib, ... }:

let
    cfg = config.custom.security.secrets;
in
{
    imports = [ inputs.sops-nix.homeManagerModules.sops ];

    options.custom.security.secrets.enable = lib.mkEnableOption "Enable secret management";

    config = lib.mkIf cfg.enable {
        # Secret management
        sops = {
            defaultSopsFile = lib.snowfall.fs.get-file "secrets/secrets.yaml";
            age = {
                # This is the default AGE key that will be used for bootstrapping the system
                keyFile = "/var/lib/sops-nix/key.txt";
            };
        };
    };
}
