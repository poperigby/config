{ config, lib, ... }:

{
    # Synchronizes Haddock's public IP with Cloudflare
    services.ddclient = {
        # TODO: Enable when running on bare metal
        enable = false;
        protocol = "cloudflare";
        zone = "haddock.cc";
        username = "poperigby@mailbox.org";
        passwordFile = config.sops."haddock/ddclient/password".path;
        domains = [ "haddock.cc" ];
    };

    # TODO: Enable when running on bare metal
    # systemd.services.ddclient = {
    #     # DynamicUser screws up sops-nix ownership because
    #     # the user doesn't exist outside of runtime.
    #     serviceConfig.DynamicUser = lib.mkForce false;
    # };

    # Setup a user and group for DDClient
    users = {
        users.ddclient = {
            group = "ddclient";
            isSystemUser = true;
        };
        groups.ddclient = {};
    };

    sops.secrets."haddock/ddclient/password".owner = "ddclient";
}
