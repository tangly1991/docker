#!/bin/sh
set -e

readonly RSYSLOG_PID="/var/run/rsyslogd.pid"

main() {
  start_keepalived
  # start_rsyslogd
  start_haproxy "$@"
}

# make sure we have keepalived's pid file not created before
start_keepalived() {
  cat > /usr/local/etc/keepalived/keepalived.conf <<__EOF__
global_defs {
    router_id ${ROUTER_ID}
    script_user root
    enable_script_security
}

vrrp_script chk_haproxy {
    script "/usr/bin/killall -0 haproxy"
    interval 2
    weight 5
    fall 3
    rise 5
    timeout 2
}

vrrp_instance VI_1 {
    interface eth0
    state ${STATE_TYPE}
    virtual_router_id 88
    priority 100
    advert_int 5
    authentication {
        auth_type PASS
        auth_pass postgres
    }
    virtual_ipaddress {
        ${VIP_IP}/24 dev eth0 label eth0:1
    }
    track_script {
        chk_haproxy
    }
}
__EOF__

  # start keepalived
  # exec /usr/sbin/keepalived --dont-fork --log-console -n -l -D -f /usr/local/etc/keepalived/keepalived.conf
}

# make sure we have rsyslogd's pid file not created before
start_rsyslogd() {
  rm -f $RSYSLOG_PID
  rsyslogd
}

# Starts the load-balancer (haproxy) with
# whatever arguments we pass to it ("$@")
start_haproxy() {
  exec /docker-entrypoint.sh "$@"
}

main "$@"
