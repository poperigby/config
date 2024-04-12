{ config, ... }:

{
    # Synchronizes Haddock's public IP with Cloudflare
    services.ddclient = {
        enable = true;
        protocol = "cloudflare";
        zone = "haddock.cc";
        username = "poperigby@mailbox.org";
        passwordFile = config.sops."haddock/ddclient/password".path;
        domains = [ "haddock.cc" ];
    };

    sops.secrets."haddock/ddclient/password".owner = "ddlcient";
}
