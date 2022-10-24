FROM registry.cn-hangzhou.aliyuncs.com/ame/haproxy:v2.7-dev8

ENV KEEPALIVED_URL https://www.keepalived.org/software/keepalived-2.2.7.tar.gz

# see https://sources.debian.net/src/haproxy/jessie/debian/rules/ for some helpful navigation of the possible "make" arguments
RUN set -eux; \
	\
	apk add --no-cache --virtual .build-deps \
		gcc \
		libc-dev \
		linux-headers \
		lua5.3-dev \
		make \
		openssl \
		openssl-dev \
		pcre2-dev \
		readline-dev \
		tar \
		libressl-dev \
		pcre2 \
		binutils \
		file \
		file-dev \
		glib \
		glib-dev \
		libnl3 \
		libnl3-dev \
		musl-dev \
		libmnl-dev \
		libnftnl-dev \
		net-snmp-dev \
		libtool \
		autoconf \
		automake \
	; \
	\
	wget -O keepalived.tar.gz "$KEEPALIVED_URL"; \
	mkdir -p /usr/src/keepalived; \
	tar -xzf keepalived.tar.gz -C /usr/src/keepalived --strip-components=1; \
	rm keepalived.tar.gz; \
	\
    cd /usr/src/keepalived; \
    ./build_setup; \
    ./configure \
		--disable-dynamic-linking \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--with-dbus-data-dir=/usr/share \
		--enable-bfd \
		--enable-dbus \
		--enable-regex \
		--enable-snmp \
		--enable-snmp-rfc \
		--enable-nftables \
		--disable-iptables \
    && make && make install \
    && strip /usr/sbin/keepalived \
    && cd - \
    && rm -rf /usr/src/keepalived

# https://www.haproxy.org/download/1.8/doc/management.txt
# "4. Stopping and restarting HAProxy"
# "when the SIGTERM signal is sent to the haproxy process, it immediately quits and all established connections are closed"
# "graceful stop is triggered when the SIGUSR1 signal is sent to the haproxy process"
STOPSIGNAL SIGUSR1

# set keepalived as image entrypoint with --dont-fork and --log-console (to make it docker friendly)
# define /etc/keepalived/keepalived.conf as the configuration file to use
# ENTRYPOINT ["/usr/sbin/keepalived", "--dont-fork", "--log-console", "-f", "/etc/keepalived/keepalived.conf"]

# example command to customise keepalived daemon:
# CMD ["--log-detail","--dump-conf"]

# Include our custom entrypoint that will the the job of lifting
# rsyslog alongside haproxy.
ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

RUN mv /usr/local/etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg.bak
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

RUN mkdir -p /config/keepalived
RUN ln -s /etc/keepalived /config/keepalived

# Set our custom entrypoint as the image's default entrypoint
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
