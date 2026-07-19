{
    inputs,
    pkgs,
    ...
}:

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
        sudo
    ];
    text = ''
        PRIVATE_CONFIG_SECRETS_FILE=${pkgs.lib.escapeShellArg "${inputs.private-config.outPath}/secrets.yaml"}
    ''
    + builtins.readFile ./script.sh;
}
