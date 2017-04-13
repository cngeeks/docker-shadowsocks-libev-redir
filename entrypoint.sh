#!/usr/bin/env bash
set -e

# ====== generate arguments ======
if [[ "${SS_UDP}" =~ ^[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|1|[Ee][Nn][Aa][Bb][Ll][Ee]$ ]]; then
    SS_UDP_FLAG="-u "
else
    SS_UDP_FLAG=""
fi
# ====== generate arguments ======


# ====== install ipset ======
echo "installing ipset ..."
ipset -f "ipset.conf" restore
# ip rule add fwmark 1/1 lookup 100
# ip route add local default dev lo table 100
echo "done ipset"
# ====== install ipset ======


# ====== generate and install iptable rules ======
echo "preparing iptables ..."
sed -i -e "s/{REMOTE_ADDR}/${SS_REDIR_TARGET_ADDR}/g" \
       -e "s/{REMOTE_PORT}/${SS_REDIR_TARGET_PORT}/g" \
       -e "s/{SS_REDIR_PORT}/${SS_REDIR_LISTEN_PORT}/g" \
       "iptables.rules"
iptables-restore "iptables.rules"
echo "done iptables"
# ====== generate and install iptable rules ======


echo "Starting Shadowsocks-libev in redir mode ..."
exec ss-redir \
     -s ${SS_REDIR_TARGET_ADDR} \
     -p ${SS_REDIR_TARGET_PORT} \
     -b ${SS_REDIR_LISTEN_ADDR} \
     -l ${SS_REDIR_LISTEN_PORT} \
     -k ${SS_PASSWORD} \
     -t ${SS_TIMEOUT} \
     -m ${SS_METHOD} \
     ${SS_UDP_FLAG} \
     >${SS_LOG} 2>&1
