{ config, pkgs, ... }:

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
      # extraOptions = [ "--pod=caddy" ];
    };

    # Setup Caddy pod
    # systemd.services.create-caddy-pod = with config.virtualisation.oci-containers; {
    #     serviceConfig.Type = "oneshot";
    #     wantedBy = [ "${backend}-caddy.service" ];
    #     script = ''
    #         ${pkgs.podman}/bin/podman pod exists caddy || \
    #         ${pkgs.podman}/bin/podman pod create -n caddy
    #     '';
    # };
}
