FROM registry.cn-hangzhou.aliyuncs.com/ame/haproxy:2.7-dev8

ENV KEEPALIVED_URL https://www.keepalived.org/software/keepalived-2.2.7.tar.gz

# see https://sources.debian.net/src/haproxy/jessie/debian/rules/ for some helpful navigation of the possible "make" arguments
RUN set -eux; \
	\
	apk add --no-cache --virtual .build-deps \
		vim \
		gcc \
		libc-dev \
		linux-headers \
		lua5.3-dev \
		make \
		pcre2-dev \
		readline-dev \
		tar \
		pcre2 \
		binutils \
		file \
		file-dev \
		glib \
		glib-dev \
		libnl3 \
		#libnl3-dev \
		#musl-dev \
		#libnftnl-dev \
		net-snmp-dev \
		libtool \
		autoconf \
		automake \
	; \
	\
	wget -O keepalived.tar.gz "$KEEPALIVED_URL"; \
	mkdir -p /usr/src/keepalived; \
	mkdir -p /usr/local/etc/keepalived; \
	chown "haproxy:haproxy" /usr/local/etc/keepalived; \
	chmod -R 744 /usr/local/etc/keepalived; \
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

# set keepalived as image entrypoint with --dont-fork and --log-console (to make it docker friendly)
# define /etc/keepalived/keepalived.conf as the configuration file to use
# ENTRYPOINT ["/usr/sbin/keepalived", "--dont-fork", "--log-console", "-f", "/etc/keepalived/keepalived.conf"]

# example command to customise keepalived daemon:
# CMD ["--log-detail","--dump-conf"]

# Include our custom entrypoint that will the the job of lifting
# rsyslog alongside haproxy.
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

RUN if [ -f "/usr/local/etc/haproxy/haproxy.cfg" ]; \
    then \
        mv /usr/local/etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg.bak; \
    fi

COPY haproxy.cfg /usr/local/etc/haproxy

RUN mkdir -p /config/haproxy
RUN mkdir -p /config/keepalived
RUN ln -s /usr/local/etc/haproxy /config/haproxy
RUN ln -s /etc/keepalived /config/keepalived

RUN cd / && ls -l && cd - && cd /usr/local/etc && ls -l && cd - && cd /usr/local/etc/haproxy && ls -l && cd - && \
    cd /var/lib && ls -l && cd - && cd /var/lib/haproxy-pid && ls -l && cd -

# https://www.haproxy.org/download/1.8/doc/management.txt
# "4. Stopping and restarting HAProxy"
# "when the SIGTERM signal is sent to the haproxy process, it immediately quits and all established connections are closed"
# "graceful stop is triggered when the SIGUSR1 signal is sent to the haproxy process"
STOPSIGNAL SIGUSR1

# Set our custom entrypoint as the image's default entrypoint
ENTRYPOINT ["/entrypoint.sh"]

CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
