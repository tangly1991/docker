FROM golang:latest AS builder

ENV DATAPLANE_MINOR 2.6.1
ENV DATAPLANE_URL https://github.com/haproxytech/dataplaneapi.git

RUN git clone "${DATAPLANE_URL}" "${GOPATH}/src/github.com/haproxytech/dataplaneapi"
RUN cd "${GOPATH}/src/github.com/haproxytech/dataplaneapi" && \
    git checkout "v${DATAPLANE_MINOR}" && \
    make build && cp build/dataplaneapi /dataplaneapi

FROM alpine:latest

MAINTAINER Dinko Korunic <dkorunic@haproxy.com>

LABEL Name HAProxy
LABEL Release Community Edition
LABEL Vendor HAProxy
LABEL Version 2.7-dev8
LABEL RUN /usr/bin/docker -d IMAGE

ENV HAPROXY_BRANCH 2.7
ENV HAPROXY_MINOR 2.7-dev8
ENV HAPROXY_SHA256 381cba4ec93205c1376eae148924f06f7f485eba9b1f953f89104d997a9e7747
ENV HAPROXY_SRC_URL http://www.haproxy.org/download

ENV DATAPLANE_MINOR 2.6.1
ENV DATAPLANE_SHA256 ec685350576898bb0a00d656f427f5da7c28043551a3e0050c1b5301547e235a
ENV DATAPLANE_URL https://github.com/haproxytech/dataplaneapi/releases/download

ENV HAPROXY_UID haproxy
ENV HAPROXY_GID haproxy

COPY --from=builder /dataplaneapi /usr/local/bin/dataplaneapi

RUN apk add --no-cache --virtual build-deps ca-certificates vim gcc libc-dev \
    linux-headers lua5.3-dev make openssl libressl-dev pcre2-dev tar \
    zlib-dev curl shadow ca-certificates && \
    curl -sfSL "${HAPROXY_SRC_URL}/${HAPROXY_BRANCH}/src/devel/haproxy-${HAPROXY_MINOR}.tar.gz" -o haproxy.tar.gz && \
    echo "$HAPROXY_SHA256 *haproxy.tar.gz" | sha256sum -c - && \
    groupadd "$HAPROXY_GID" && \
    useradd -g "$HAPROXY_GID" "$HAPROXY_UID" && \
    mkdir -p /tmp/haproxy && \
    tar -xzf haproxy.tar.gz -C /tmp/haproxy --strip-components=1 && \
    rm -f haproxy.tar.gz && \
    make -C /tmp/haproxy -j"$(nproc)" TARGET=linux-musl CPU=generic USE_PCRE2=1 USE_PCRE2_JIT=1 USE_OPENSSL=1 \
                            USE_TFO=1 USE_LINUX_TPROXY=1 USE_GETADDRINFO=1 \
                            USE_LUA=1 LUA_LIB=/usr/lib/lua5.3 LUA_INC=/usr/include/lua5.3 \
                            USE_PROMEX=1 USE_SLZ=1 \
                            all && \
    make -C /tmp/haproxy TARGET=linux2628 install-bin install-man && \
    ln -s /usr/local/sbin/haproxy /usr/sbin/haproxy && \
    mkdir -p /var/lib/haproxy && \
    chown "$HAPROXY_UID:$HAPROXY_GID" /var/lib/haproxy && \
    chmod -R 777 /var/lib/haproxy && \
    mkdir -p /usr/local/etc/haproxy && \
    mkdir -p /var/lib/haproxy-pid && \
    chown "$HAPROXY_UID:$HAPROXY_GID" /var/lib/haproxy-pid && \
    chmod -R 777 /var/lib/haproxy-pid && \
    ln -s /usr/local/etc/haproxy /etc/haproxy && \
    cp -R /tmp/haproxy/examples/errorfiles /usr/local/etc/haproxy/errors && \
    rm -rf /tmp/haproxy && \
    chmod +x /usr/local/bin/dataplaneapi && \
    ln -s /usr/local/bin/dataplaneapi /usr/bin/dataplaneapi && \
    touch /usr/local/etc/haproxy/dataplaneapi.hcl && \
    chown "$HAPROXY_UID:$HAPROXY_GID" /usr/local/etc/haproxy/dataplaneapi.hcl && \
    apk del build-deps && \
    apk add --no-cache openssl libressl-dev zlib lua5.3-libs pcre2 && \
    rm -f /var/cache/apk/*

COPY haproxy.cfg /usr/local/etc/haproxy
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

RUN cd / && ls -l && cd - && cd /usr/local/etc/haproxy && ls -l && cd -

STOPSIGNAL SIGUSR1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
