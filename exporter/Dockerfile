FROM debian:bullseye-slim

ADD postgres_exporter-0.11.1.linux-amd64.tar.gz /
ADD haproxy_exporter-0.13.0.linux-amd64.tar.gz /

ADD node-v16.18.0-linux-x64.tar.xz /
ADD etcd-browser-master.tar.gz /

ADD postgres-exporter.sh /
ADD haproxy-exporter.sh /
ADD etcd-browser.sh /
ADD entrypoint.sh /

RUN chmod +x /postgres-exporter.sh
RUN chmod +x /haproxy-exporter.sh
RUN chmod +x /etcd-browser.sh
RUN chmod +x /entrypoint.sh

# Set our custom entrypoint as the image's default entrypoint
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
