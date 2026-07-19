{
    inputs,
    pkgs,
    ...
}:

let
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
        PRIVATE_CONFIG_SECRETS_FILE=${pkgs.lib.escapeShellArg "${inputs.private-config.outPath}/secrets.yaml"}
    ''
    + builtins.readFile ./script.sh;
}
