#!/bin/bash

main() {
  start_pg_exporter
  start_haproxy_exporter
  start_etcdbrowser
}

start_pg_exporter() {
  exec /postgres-exporter.sh
}

start_haproxy_exporter() {
  exec /haproxy-exporter.sh
}

start_etcdbrowser() {
  exec /etcd-browser.sh
}

main
