#!/bin/bash

if [[ $UID -ge 10000 ]]; then
  GID=$(id -g)
  sed -e "s/^postgres:x:[^:]*:[^:]*:/postgres:x:$UID:$GID:/" /etc/passwd > /tmp/passwd
  cat /tmp/passwd > /etc/passwd
  rm /tmp/passwd
fi

cat > /home/postgres/patroni.yml <<__EOF__
scope: ${PATRONI_SCOPE}
namespace: /service
name: ${PATRONI_NAME}

log:
  level: INFO
  traceback_level: ERROR
  dir: /home/patroni/log
  file_num: 10
  file_size: 104857600

restapi:
  listen: 0.0.0.0:8008
  connect_address: ${PATRONI_POD_IP}:8008

etcd:
  host: ${PATRONI_ETCD_POD_IP}:2379

bootstrap:
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 864000000
    maximum_lag_on_failover: 1048576
    master_start_timeout: 300
    synchronous_mode: true
    postgresql:
      use_pg_rewind: true
      use_slots: true
      parameters:
        listen_addresses: 0.0.0.0
        port: 5432
        wal_level: replica
        hot_standby: "on"
        wal_keep_size: 100
        max_wal_senders: 10
        max_replication_slots: 10
        wal_log_hints: "on"
  initdb:
  - auth-host: md5
  - auth-local: trust
  - encoding: UTF8
  - locale: C
  - lc-collate: zh_CN.UTF-8
  - lc-ctype: zh_CN.UTF-8
  - lc-messages: zh_CN.UTF-8
  - lc-monetary: zh_CN.UTF-8
  - lc-numeric: zh_CN.UTF-8
  - lc-time: zh_CN.UTF-8
  - data-checksums
  pg_hba:
  - host all all 0.0.0.0/0 md5
  - host replication ${PATRONI_REPLICATION_USERNAME} ${PATRONI_POD_IP}/16 md5

postgresql:
  listen: 0.0.0.0:5432
  connect_address: ${PATRONI_POD_IP}:5432
  data_dir: ${PATRONI_POSTGRESQL_DATA_DIR}
  pgpass: ${PATRONI_POSTGRESQL_PGPASS}
  pg_ctl_timeout: 60
  use_pg_rewind: true
  remove_data_directory_on_rewind_failure: false
  remove_data_directory_on_diverged_timelines: true
  authentication:
    superuser:
      username: ${PATRONI_SUPERUSER_USERNAME}
      password: ${PATRONI_SUPERUSER_PASSWORD}
    replication:
      username: ${PATRONI_REPLICATION_USERNAME}
      password: ${PATRONI_REPLICATION_PASSWORD}
  callbacks:
    on_start: /callback.sh
    on_role_change: /callback.sh
__EOF__

unset PATRONI_SUPERUSER_PASSWORD PATRONI_REPLICATION_PASSWORD

exec /usr/bin/python3 /usr/local/bin/patroni /home/postgres/patroni.yml
