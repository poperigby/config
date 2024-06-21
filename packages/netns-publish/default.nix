# https://github.com/dadevel/wg-netns/blob/main/extras/netns-publish.sh

{
    socat,
    writeShellScriptBin,
    ...
}:

writeShellScriptBin "netns-publish" ''
    set -eu

    if [ $# -ne 3 ]; then
        echo 'usage: netns-publish PUBLIC_PORT NETNS_NAME NETNS_ADDRESS:NETNS_PORT'
        exit 1
    fi

    exec ${socat}/bin/socat tcp-listen:"$1",reuseaddr,fork "exec:ip netns exec $2 socat stdio 'tcp-connect:$3',nofork"
''
