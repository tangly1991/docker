#!/bin/bash

set -o errexit
set -o nounset

main() {
  start_keepalived
}

# make sure we have keepalived's pid file not created before
start_keepalived() {
  cat > /etc/keepalived/keepalived.conf <<__EOF__
global_defs {
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
        ${VIPADDR_IP}/24 dev eth0 label eth0:1
    }
    track_script {
        chk_haproxy
    }
}
__EOF__

  # start keepalived
  exec /usr/sbin/keepalived --dont-fork --log-console -n -l -D -f /etc/keepalived/keepalived.conf
}

main
