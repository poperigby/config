{ ... }:

{
    # How can I use my secrets for Caddy stuff?
    virtualisation.oci-containers.containers.caddy = {
        image = "ghcr.io/poperigby/caddy:latest";
        hostname = "caddy";
        volumes = [
            "${./Caddyfile}:/etc/caddy/Caddyfile"
            "caddy-config:/config"
            "caddy-data:/data"
        ];
    };
}
