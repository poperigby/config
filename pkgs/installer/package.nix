{
    inputs,
    pkgs,
    ...
}:

let
    inherit (pkgs) lib;
    inventory = (import ../../modules/inventory.nix { inherit inputs; }).den.hosts;
    installableHosts = builtins.filter (host: host != "skut") (
        builtins.attrNames inventory.${pkgs.stdenv.hostPlatform.system}
    );
    privateInfo = (import "${inputs.private-config.outPath}/modules/private-info.nix" { }).den.aspects.privateInfo;
in

pkgs.writeShellApplication {
    name = "installer";
    runtimeInputs = with pkgs; [
        age
        bitwarden-cli
        coreutils
        disko
        findutils
        git
        gnugrep
        gum
        jq
        sops
    ];
    text = ''
        BITWARDEN_EMAIL=${pkgs.lib.escapeShellArg privateInfo.cassidy.email}
        INSTALLABLE_HOSTS=${lib.escapeShellArg (lib.concatStringsSep " " installableHosts)}
        PRIVATE_CONFIG_SECRETS_FILE=${pkgs.lib.escapeShellArg "${inputs.private-config.outPath}/secrets.yaml"}
    ''
    + builtins.readFile ./script.sh;
}
