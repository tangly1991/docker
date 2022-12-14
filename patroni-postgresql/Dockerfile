FROM postgres:15.0
MAINTAINER Alexander Kukushkin <alexander.kukushkin@zalando.de>

RUN export DEBIAN_FRONTEND=noninteractive \
    && echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > /etc/apt/apt.conf.d/01norecommend \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-cache depends patroni | sed -n -e 's/.* Depends: \(python3-.\+\)$/\1/p' \
            | grep -Ev '^python3-(sphinx|etcd|consul|kazoo|kubernetes)' \
            | xargs apt-get install -y vim-tiny telnet curl jq locales git python3-pip python3-wheel \
    ## Make sure we have a en_US.UTF-8 locale available
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8 \
    && pip3 install setuptools \
    && pip3 install patroni[etcd3] \
    && PGHOME=/home/postgres \
    && mkdir -p $PGHOME \
    && mkdir -p /home/patroni/log \
    && chown postgres $PGHOME \
    && chown postgres /home/patroni/log \
    && sed -i "s|/var/lib/postgresql.*|$PGHOME:/bin/bash|" /etc/passwd \
    # Set permissions for OpenShift
    && chmod 775 $PGHOME \
    && chmod 775 /home/patroni/log \
    && chmod 664 /etc/passwd \
    # Clean up
    && apt-get remove -y git python3-pip python3-wheel \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /root/.cache

ADD entrypoint.sh /
ADD callback.sh /
RUN chmod +x /entrypoint.sh
RUN chmod +x /callback.sh
RUN apt-get update -y && apt-get install iputils-ping -y

EXPOSE 5432 8008
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 EDITOR=/usr/bin/editor
USER postgres
WORKDIR /home/postgres
CMD ["/bin/bash", "/entrypoint.sh"]
