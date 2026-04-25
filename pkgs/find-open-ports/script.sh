PORT_START=${1:-1024}
PORT_END=${2:-65535}

USED_PORTS=$(ss -Htan | awk '{split($4,a,":"); print a[length(a)]}' | sort -n | uniq)
declare -A USED
for port in $USED_PORTS; do
    USED["$port"]=1
done

for ((port=PORT_START; port<=PORT_END; port++)); do
    if [[ -z "${USED[$port]}" ]]; then
        echo "$port"
        exit 0
    fi
done

echo "No available ports found in range $PORT_START-$PORT_END" >&2
exit 1

