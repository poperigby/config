{
  inputs,
  pkgs,
  system,
  ...
}:

{
  imports = [ ./mods.nix ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers.fabric = {
      enable = true;
      package = inputs.nix-minecraft.legacyPackages.${system}.fabricServers.fabric-1_21_4;
      serverProperties = {
        server-name = "Haddock";
        allow-cheats = true;
        difficulty = "normal";
      };
      symlinks = {
        "ops.json" =
          let
            inherit (pkgs) writeTextFile;
          in
          writeTextFile {
            name = "ops.json";
            text = # json
              ''
                [
                    {
                        "uuid": "856e015c-7937-49d8-80dc-35ccdf96e3c2",
                        "name": "jujubunicorn",
                        "level": 4,
                        "bypassesPlayerLimit": true
                    },
                    {
                        "uuid": "945a016d-b341-453c-8dca-cc16091088ca",
                        "name": "PopeRigby",
                        "level": 4,
                        "bypassesPlayerLimit": true
                    },
                    {
                        "uuid": "8131a51c-51e1-46b2-9ce4-8376c00712a3",
                        "name": "TootyFart",
                        "level": 4,
                        "bypassesPlayerLimit": true
                    }
                ]
              '';
          };
      };
    };
  };
}
