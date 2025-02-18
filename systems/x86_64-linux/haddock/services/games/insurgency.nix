{
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) isString;
  inherit (lib.generators) toKeyValue mkKeyValueDefault;
  inherit (pkgs) fetchSteam mkSteamServer writeText;

  mkConfig =
    config:
    writeText "server.cfg" (
      toKeyValue {
        mkKeyValue = mkKeyValueDefault {
          mkValueString =
            value:
            if isString value then
              # Strings must be quoted
              ''"${value}"''
            else if value == true then
              ''1''
            else if value == false then
              ''0''
            else
              ''${toString value}'';
        } " ";
      } config
    );

in
{
  flux.servers.insurgencySandstorm = {
    package = mkSteamServer rec {
      name = "insurgency_sandstorm";
      src = fetchSteam {
        inherit name;
        appId = "581330";
        hash = "sha256-tFlltXxbEn/6DD8NIaAnYajQVwGz0WyTJNYSw9XbDyE=";
      };
      startCmd =
        let
          binary = "Insurgency/Binaries/Linux/InsurgencyServer-Linux-Shipping";
          config = mkConfig {
            ## Server
            hostname = "Haddock";
            ## Game
            mp_friendlyfire = true;
          };
          port = 27015;
        in
        # bash
        ''
          ${binary} +servercfgfile ${config} -console -port ${toString port}
        '';
      hash = "sha256-tFlltXxbEn/6DD8NIaAnYajQVwGz0WyTJNYSw9XbDyE=";
    };
  };
}
