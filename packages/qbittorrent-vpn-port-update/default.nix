{
    lib,
    pkgs,
    ...
}:

lib.custom.createShellScript {
    inherit pkgs;

    pname = "qbittorrent-vpn-port-update";
    src = ./script.sh;
    deps = with pkgs; [
        curl
        gawk
        iptables
        jq
        libnatpmp
    ];
}
