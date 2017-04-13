#
# Dockerfile for shadowsocks-libev redir mode
#

FROM lisnaz/shadowsocks-libev
MAINTAINER Vincent Gu <g@v-io.co>

ENV SS_REDIR_LISTEN_ADDR       127.0.0.1
ENV SS_REDIR_LISTEN_PORT       8388
ENV SS_REDIR_TARGET_ADDR       127.0.0.1
ENV SS_REDIR_TARGET_PORT       8388

# define service ports
EXPOSE $SS_REDIR_LISTEN_PORT/tcp
EXPOSE $SS_REDIR_LISTEN_PORT/udp

# copy iptables rules
ADD iptables.rules .

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

# generate china ipset
RUN set -ex \
    && echo 'create china hash:net' >> ipset.conf \
    && curl 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' \
        | grep ipv4 \
        | grep CN \
        | awk -F\| '{printf(add china "%s/%d\n", $4, 32-log($5)/log(2))}' >> ipset.conf
