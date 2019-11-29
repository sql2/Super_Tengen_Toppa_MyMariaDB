###############################################################################
# Dockerfile to build Orchestrator container images
# Based on Centos 7
###############################################################################

# Set the base image to Centos 7
FROM centos:7

# File Author / Maintainer
MAINTAINER hyeongchae@gmail.com 

LABEL vendor="MySQL Korea User Group" \
      description="MariaDB Server on Centos 7" \
      version="10.4.10"

ENV container docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

# Update the repository sources list
RUN yum -y --setopt=tsflags=nodocs update

# Install additional repository and add repository key
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

###############################################################################
# BEGIN INSTALLATION
###############################################################################
# -----------------------------------------------------------------------------
# Install additional packages
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install epel-release wget unzip dnsmasq bind-utils


# -----------------------------------------------------------------------------
# Install jq
# -----------------------------------------------------------------------------
ADD https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 /usr/local/bin/
RUN chmod +x /usr/local/bin/jq-linux64 && \
                mv /usr/local/bin/jq-linux64 /usr/local/bin/jq


# -----------------------------------------------------------------------------
# Install MariaDB Server
# -----------------------------------------------------------------------------
COPY MariaDB.repo /etc/yum.repos.d/MariaDB.repo

RUN yum -y update && yum -y --setopt=tsflags=nodocs install MariaDB-server

COPY mysql-clients.cnf server.cnf /etc/my.cnf.d/

COPY create_user.sql /root/create_user.sql


# -----------------------------------------------------------------------------
# Install pmm-client, pt-xtrabackup
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
RUN percona-release disable all
RUN percona-release enable tools
RUN yum -y --setopt=tsflags=nodocs install pmm-client percona-xtrabackup


# -----------------------------------------------------------------------------
# Install Consul
# -----------------------------------------------------------------------------
ADD https://releases.hashicorp.com/consul/1.6.2/consul_1.6.2_linux_amd64.zip /root/
RUN unzip /root/consul_1.6.2_linux_amd64.zip -d /root/ && \
    rm -f /root/consul_1.6.2_linux_amd64.zip && \
    mv /root/consul /usr/local/bin/ && \
    mkdir -p /etc/consul.d/

COPY consul_client.json /etc/consul.d/consul_client.json
COPY consul.service /usr/lib/systemd/system/consul.service
RUN systemctl enable consul.service


# -----------------------------------------------------------------------------
# Install vault
# -----------------------------------------------------------------------------
ADD https://releases.hashicorp.com/vault/1.3.0/vault_1.3.0_linux_amd64.zip /root/
RUN unzip /root/vault_1.3.0_linux_amd64.zip -d /root/ && \
    rm -f /root/vault_1.3.0_linux_amd64.zip && \
    mv /root/vault /usr/local/bin/ && \
    mkdir -p /etc/vault.d/

COPY dba_policy.hcl /root/dba_policy.hcl 
COPY dev_policy.hcl /root/dev_policy.hcl 

# -----------------------------------------------------------------------------
# Install dnsmasq
# -----------------------------------------------------------------------------
COPY 10-consul /etc/dnsmasq.d
COPY consul.service /usr/lib/systemd/system/consul.service
RUN systemctl enable dnsmasq.service

# -----------------------------------------------------------------------------
# Copy script utility
# -----------------------------------------------------------------------------
COPY provisioning.sh /root/provisioning.sh
RUN chmod a+x /root/provisioning.sh


# -----------------------------------------------------------------------------
# Clear
# -----------------------------------------------------------------------------
RUN yum -y clean all && \
    rm -rf /var/cache/yum/*

############################## INSTALLATION END ###############################

# Expose the default MySQL/Mariadb port
EXPOSE 53/udp 53 80 443 389 636 88 464 88/udp 464/udp 123/udp 3306

# Start service on run container
ENTRYPOINT ["/sbin/init"]

STOPSIGNAL SIGRTMIN+3
