{ config, lib, ... }:

let
  inherit (lib) mkForce;

  cfg = config.services.atticd;
  port = 8084;
in
{
  services = {
    atticd = {
      enable = true;
      environmentFile = config.sops.templates.attic-environment-file.path;
      # https://github.com/zhaofengli/attic/blob/main/server/src/config-template.toml
      settings = {
        listen = "[::]:${toString port}";
        jwt = { };
        chunking = {
          # The minimum NAR size to trigger chunking
          #
          # If 0, chunking is disabled entirely for newly-uploaded NARs.
          # If 1, all NARs are chunked.
          nar-size-threshold = 64 * 1024; # 64 KiB

          # The preferred minimum size of a chunk, in bytes
          min-size = 16 * 1024; # 16 KiB

          # The preferred average size of a chunk, in bytes
          avg-size = 64 * 1024; # 64 KiB

          # The preferred maximum size of a chunk, in bytes
          max-size = 256 * 1024; # 256 KiB
        };
      };
    };
    caddy.virtualHosts."cache.haddock.cc".extraConfig = ''
      reverse_proxy :${toString port}
    '';
  };

  systemd.services.atticd.serviceConfig.DynamicUser = mkForce false;

  users = {
    users.atticd = {
      group = "atticd";
      isSystemUser = true;
    };
    groups.atticd = { };
  };

  sops = {
    templates.attic-environment-file = {
      owner = cfg.user;
      content = # bash
        ''
          ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=${config.sops.placeholder."haddock/attic/server_token"}
        '';
    };
    secrets."haddock/attic/server_token".owner = cfg.user;
  };
}
