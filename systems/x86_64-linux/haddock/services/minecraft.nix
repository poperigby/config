{
  inputs,
  lib,
  pkgs,
  system,
  ...
}:

{
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
        mods =
          let
            inherit (lib) attrValues;
            inherit (pkgs) fetchurl linkFarmFromDrvs;
          in
          linkFarmFromDrvs "mods" (attrValues {
            c2me = fetchurl {
              url = "https://cdn.modrinth.com/data/VSNURh3q/versions/c8KSyi6D/c2me-fabric-mc1.21.4-0.3.1%2Brc.1.0.jar";
              sha512 = "ea436b38ffd5183711e77615793654bfe7d97d2ec408149e81e0d06f854c924b373a5f6ae0740fdc177caebef3b2c41b11d92c6a313295973488f38efda57f59";
            };
            debugify = fetchurl {
              url = "https://cdn.modrinth.com/data/QwxR6Gcd/versions/TxwUizo2/Debugify-1.21.4%2B1.0.jar";
              sha512 = "9108fc2e114400ea72698b07fdf805c708e453e374b3794ebc8afcc2bd6e60cda9297b86fedae49b3b044704cebcde430f98aae3fd9db355ef0518a2887548b8";
            };
            fabricAPI = fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/15ijyoD6/fabric-api-0.113.0%2B1.21.4.jar";
              sha512 = "42f63c2e27fed66409d907a6ee28946f4caaabf2c6443eafc8a115e12e4278ccd7218bc6593495adba3111dc9ac97710210797608c2a88e2a71453fc34096a99";
            };
            ferriteCore = fetchurl {
              url = "https://cdn.modrinth.com/data/uXXizFIs/versions/IPM0JlHd/ferritecore-7.1.1-fabric.jar";
              sha512 = "f41dc9e8b28327a1e29b14667cb42ae5e7e17bcfa4495260f6f851a80d4b08d98a30d5c52b110007ee325f02dac7431e3fad4560c6840af0bf347afad48c5aac";
            };
            lithium = fetchurl {
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/t1FlWYl9/lithium-fabric-0.14.3%2Bmc1.21.4.jar";
              sha512 = "1a4eafbdcee3886d33c04aa462d13a8c1e345ff492001add262476585b78327a2d016e56385bced869615bc97161a34a0a716f5f579c8c1d7080b278f4f11183";
            };
            modernFix = fetchurl {
              url = "https://cdn.modrinth.com/data/nmDcB62a/versions/A84EEUXb/modernfix-fabric-5.20.0%2Bmc1.21.4.jar";
              sha512 = "7545b84be292b29880e77a317b83d51fe9ae26dd2197fa0f1fafaf038f07b632cb3054d5bd6158276dade3e3284b90284556392c61025e54517dafc395670678";
            };
            noChatReports = fetchurl {
              url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/9xt05630/NoChatReports-FABRIC-1.21.4-v2.11.0.jar";
              sha512 = "d343b05c8e50f1de15791ff622ad44eeca6cdcb21e960a267a17d71506c61ca79b1c824167779e44d778ca18dcbdebe594ff234fbe355b68d25cdb5b6afd6e4f";
            };
            pingWheel = fetchurl {
              url = "https://cdn.modrinth.com/data/QQXAdCzh/versions/j4MXM9sv/Ping-Wheel-1.10.0-fabric-1.21.4.jar";
              sha512 = "424d97183ae963c557c5f729a881e6e547021648a98e21d7ccc473fdfd4687393f0a259fff0abdf8a8b87983bf05d4b8aeaf7858c0993115351327f2afe137db";
            };
            polymer = fetchurl {
              url = "https://cdn.modrinth.com/data/xGdtZczs/versions/aek1vsQ6/polymer-bundled-0.11.3%2B1.21.4.jar";
              sha512 = "17e4238ddbe4151e0f074955a00bdd788449d8c100a9465ecb6da155527689501442cbcc5cb4eb05943e6b525286d3a7f5a10c7fc0ba91cec2614260d6f1efbb";
            };
            scalableLux = fetchurl {
              url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/DUpB8IQV/ScalableLux-0.1.1%2Bfabric.452731d-all.jar";
              sha512 = "2f985e3bcca07eea0771ab5a88eca433460510f11af0efdfa01d2ffeb5f8628b3a12100ec50db2d2aa9567dd11684e027d9442be16f7e658ce5946706d9e4f6b";
            };
            serverCore = fetchurl {
              url = "https://cdn.modrinth.com/data/4WWQxlQP/versions/uJYh4tBK/servercore-fabric-1.5.8%2B1.21.4.jar";
              sha512 = "5fe7feb62487d54b3779d4418a675b82be817b3e35a808f320582e4efec2422454c8a129793f0c11c9eb8a0f406c0f7e2003d46c936416a2bfea6a5f85a4ead2";
            };
            serverSideWaystones = fetchurl {
              url = "https://cdn.modrinth.com/data/BzV6ulv0/versions/CLdbeNYb/sswaystones-1.1.5.jar";
              sha512 = "086c8d032f36a7b49f98eb1459712134e66cfc40f5b32a9caf509cc87ae9eb17f2dc5f716ce3a55492f7286de167f27b704365ad4dffdd63e2ae5e38b4cb8cd4";
            };
            sleep = fetchurl {
              url = "https://cdn.modrinth.com/data/WTzuSu8P/versions/3rFkoWwZ/sleep-v.3.1.1.jar";
              sha512 = "329f2d8cd2d657c500ed0fa2aa20223e955b20c223ac7096bbf1b6d967ea4112f9d9b8ed198190e6b8a0ccfc4860787d2f0cec8b4b1671b40d801e8baee4ec05";
            };
            stoneIsStone = fetchurl {
              url = "https://cdn.modrinth.com/data/P4chhBIh/versions/LZ4YUdvo/stone-is-stone-1.1.0%2Bmc1.21.2.jar";
              sha512 = "ebc75753db8aa902f4b84643e0e5be8d0cf806242cddc61a77afb66864ba5dfdb6d54755f8d9fc29f4c5dccdb6556c6f6a4b7c1fddf63a2af0a8ca1c9667e910";
            };
            terralith = fetchurl {
              url = "https://cdn.modrinth.com/data/8oi3bsk5/versions/lQreFvOm/Terralith_1.21.x_v2.5.7.jar";
              sha512 = "43d40bfe8dce603b7c9ebeb72db389e277cd3055414629350f2883a6c76472a887ac350a95d9ec55c28aec165dee773640462cb674cdc4c3efb30099f3463b72";
            };
            timber = fetchurl {
              url = "https://cdn.modrinth.com/data/xmgjZzfd/versions/34c2B4by/timber-r1.2.1%2B1.21.4.jar";
              sha512 = "f50368a36407794b4dfbba8ce2628c62f79623bf61da94ade92ce33ae6ff827ad92a7681664234bf9b95fee82d19d530919c35b241cddae368ff3d5871ba7930";
            };
            universalGraves = fetchurl {
              url = "https://cdn.modrinth.com/data/yn9u3ypm/versions/o2f2Idvu/graves-3.6.0%2B1.21.4.jar";
              sha512 = "b0dffe29f4218bb02a8fea29e9ba0f39c2bf93a671d5f2f071afba8a3bc0ab036a00606ef25aa8a6e4b9f67123ffd4eab78c67e18ca34a5aea5cd18915adeee5";
            };
            xaerosWorldMap = fetchurl {
              url = "https://cdn.modrinth.com/data/NcUtCpym/versions/BnFw7PFl/XaerosWorldMap_1.39.2_Fabric_1.21.4.jar";
              sha512 = "36c7b9036aa3a2899e4758cc935370ba1e7bf41f8ae0eb25d301ae2f18591bb0e4abfa748c968abd3edd471857ae7dc211217ea07d50ecbd8300df25678008a5";
            };
          });
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
