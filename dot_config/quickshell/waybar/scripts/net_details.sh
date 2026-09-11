#!/usr/bin/env bash

rte=$(ip -o route show default 2>/dev/null | head -n1)
iface=$(awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' <<< "$rte")
[ -n "$iface" ] || exit 0
gw=$(awk '{for(i=1;i<=NF;i++) if($i=="via") print $(i+1)}' <<< "$rte")
ip4=$(ip -o -4 addr show dev "$iface" 2>/dev/null | awk '{print $4; exit}' | cut -d/ -f1)
rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null)
tx=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null)
pg=$(ping -c1 -W1 -q "$gw" 2>/dev/null | awk -F/ '/rtt min|round-trip/ {print $5; exit}')
pn=$(ping -c1 -W1 -q 1.1.1.1 2>/dev/null | awk -F/ '/rtt min|round-trip/ {print $5; exit}')
printf 'iface\t%s\nip\t%s\ngateway\t%s\nrx\t%s\ntx\t%s\nping_gw\t%s\nping_net\t%s\n' \
    "$iface" "$ip4" "$gw" "$rx" "$tx" "$pg" "$pn"

vcount=$(ip -o link show type wireguard 2>/dev/null | wc -l | tr -d ' ')
vif=$(ip -o link show type wireguard 2>/dev/null | awk -F: 'NR==1 {print $2}' | tr -d ' ')
vip=""; vend=""; vrx=""; vtx=""
if [ -n "$vif" ]; then
    vip=$(ip -o -4 addr show dev "$vif" 2>/dev/null | awk '{print $4; exit}' | cut -d/ -f1)
    wgi=$(wg show "$vif" 2>/dev/null)
    vend=$(awk '/endpoint:/ {print $2; exit}' <<< "$wgi")
    vrx=$(awk '/transfer:/ {for(i=1;i<=NF;i++) if($(i)=="received,") {v=$(i-2); u=$(i-1); exit}} END {m=1; if(u=="KiB")m=1024; else if(u=="MiB")m=1048576; else if(u=="GiB")m=1073741824; else if(u=="TiB")m=1099511627776; printf "%d", v*m+0}' <<< "$wgi")
    vtx=$(awk '/transfer:/ {for(i=1;i<=NF;i++) if($(i)=="sent") {v=$(i-2); u=$(i-1); exit}} END {m=1; if(u=="KiB")m=1024; else if(u=="MiB")m=1048576; else if(u=="GiB")m=1073741824; else if(u=="TiB")m=1099511627776; printf "%d", v*m+0}' <<< "$wgi")
fi
printf 'vpn_count\t%s\nvpn_name\t%s\nvpn_ip\t%s\nvpn_endpoint\t%s\nvpn_rx\t%s\nvpn_tx\t%s\n' \
    "$vcount" "$vif" "$vip" "$vend" "$vrx" "$vtx"
