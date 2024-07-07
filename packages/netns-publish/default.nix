# https://github.com/dadevel/wg-netns/blob/main/extras/netns-publish.sh

{
    pkgs,
    writeShellScriptBin,
    ...
}:

let
    socat = "${pkgs.socat}/bin/socat";
    ip = "${pkgs.iproute2}/bin/ip";
in
writeShellScriptBin "netns-publish" ''
    set -eu

    EXTERNAL_PORT=$1
    NAMESPACE_NAME=$2

    if [ $# -ne 3 ]; then
        echo 'usage: netns-publish PUBLIC_PORT NETNS_NAME NETNS_ADDRESS:NETNS_PORT'
        exit 1
    fi

    exec ${socat} tcp-listen:"$EXTERNAL_PORT",reuseaddr,fork "exec:${ip} netns exec $NAMESPACE_NAME ${socat} stdio 'tcp-connect:$3',nofork"
''
