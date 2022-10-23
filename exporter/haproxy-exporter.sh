#!/bin/bash

tar -zxvf /haproxy_exporter-0.13.0.linux-amd64.tar.gz
mv /haproxy_exporter-0.13.0.linux-amd64/haproxy_exporter /usr/local/bin/haproxy_exporter

rm -rf /haproxy_exporter-0.13.0.linux-amd64.tar.gz


nohup haproxy_exporter --web.listen-address=":9101" --haproxy.scrape-uri="http://admin:admin@pglb0:1080/haproxy?stats;csv"  > /dev/null 2>&1 &
nohup haproxy_exporter --web.listen-address=":9102" --haproxy.scrape-uri="http://admin:admin@pglb1:1080/haproxy?stats;csv"  > /dev/null 2>&1 &

netstat -tulnp | grep 91
