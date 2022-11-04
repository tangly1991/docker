# vim:set ft=dockerfile:
FROM rockylinux:9

ENV MXS_VERSION=22.08.2

RUN groupadd maxscale; \
    useradd -g maxscale maxscale

# Add MariaDB Enterprise Repo
RUN curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | \
    bash -s -- --mariadb-maxscale-version=${MXS_VERSION} --apply

# Update System
RUN dnf -y install epel-release && \
    dnf -y upgrade

# Install Some Basic Dependencies & MaxScale
RUN dnf clean expire-cache && \
    dnf -y install bind-utils \
    findutils \
    less \
    maxscale \
    monit \
    nano \
    ncurses \
    net-tools \
    openssl \
    procps-ng \
    rsyslog \
    vim \
    wget

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
 && gpg --batch --verify /tini.asc /usr/bin/tini
RUN chmod +x /usr/bin/tini

# Copy Files To Image
COPY config/maxscale.cnf /etc/

COPY config/monit.d/ /etc/monit.d/

COPY scripts/maxscale-start \
    scripts/maxscale-stop \
    scripts/maxscale-restart \
    /usr/bin/

# Chmod Some Files
RUN chmod +x /usr/bin/maxscale-start \
    /usr/bin/maxscale-stop \
    /usr/bin/maxscale-restart

# Expose MariaDB Port
EXPOSE 3306

# Expose REST API port
EXPOSE 8989

# Create Persistent Volume
VOLUME ["/var/lib/maxscale"]

# Copy Entrypoint To Image
COPY scripts/docker-entrypoint.sh /usr/bin/

# Make Entrypoint Executable & Create Legacy Symlink
RUN chmod +x /usr/bin/docker-entrypoint.sh && \
    ln -s /usr/bin/docker-entrypoint.sh /docker-entrypoint.sh

# Clean System & Reduce Size
RUN dnf clean all && \
    rm -rf /var/cache/dnf && \
    sed -i 's|SysSock.Use="off"|SysSock.Use="on"|' /etc/rsyslog.conf && \
    sed -i 's|^.*module(load="imjournal"|#module(load="imjournal"|g' /etc/rsyslog.conf && \
    sed -i 's|^.*StateFile="imjournal.state")|#  StateFile="imjournal.state"\)|g' /etc/rsyslog.conf && \
    find /var/log -type f -exec cp /dev/null {} \; && \
    cat /dev/null > ~/.bash_history && \
    history -c

RUN mkdir -p /data/maxscale/ && \
    mkdir -p /data/maxscale/log/ && \
    mkdir -p /data/maxscale/data/
    chown maxscale /data/maxscale/log/ && \
    chown maxscale /data/maxscale/data/

# Start Up
ENTRYPOINT ["/usr/bin/tini","--","docker-entrypoint.sh"]

CMD maxscale-start && monit -I
