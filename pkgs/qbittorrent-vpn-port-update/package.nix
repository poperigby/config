{
    pkgs,
    ...
}:

pkgs.writeShellApplication {
    name = "qbittorrent-vpn-port-update";
    runtimeInputs = with pkgs; [
        curl
        gawk
        iptables
        jq
        libnatpmp
    ];
    text = builtins.readFile ./script.sh;
}
