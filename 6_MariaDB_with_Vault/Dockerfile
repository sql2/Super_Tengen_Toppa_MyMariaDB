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
      version="10.4 stable"

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
# Install IPA Client
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install freeipa-client ipa-admintools pam-devel


# -----------------------------------------------------------------------------
# Install MariaDB Server
# -----------------------------------------------------------------------------
COPY MariaDB.repo /etc/yum.repos.d/MariaDB.repo

RUN yum -y update && yum -y --setopt=tsflags=nodocs install MariaDB-server

COPY mysql-clients.cnf server.cnf /etc/my.cnf.d/


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
ADD https://releases.hashicorp.com/consul/1.7.2/consul_1.7.2_linux_amd64.zip /root/
RUN unzip /root/consul_1.7.2_linux_amd64.zip -d /root/ && \
    rm -f /root/consul_1.7.2_linux_amd64.zip && \
    mv /root/consul /usr/local/bin/ && \
    mkdir -p /etc/consul.d/

COPY consul_client.json /etc/consul.d/consul_client.json


# -----------------------------------------------------------------------------
# Install vault
# -----------------------------------------------------------------------------
ADD https://releases.hashicorp.com/vault/1.4.1/vault_1.4.1_linux_amd64.zip /root/
RUN unzip /root/vault_1.4.1_linux_amd64.zip -d /root/ && \
    rm -f /root/vault_1.4.1_linux_amd64.zip && \
    mv /root/vault /usr/local/bin/ && \
    mkdir -p /etc/vault.d/

COPY dba_policy.hcl /root/dba_policy.hcl 
COPY dev_policy.hcl /root/dev_policy.hcl 

# -----------------------------------------------------------------------------
# Install dnsmasq
# -----------------------------------------------------------------------------
COPY 10-consul /etc/dnsmasq.d

# -----------------------------------------------------------------------------
# Copy script utility
# -----------------------------------------------------------------------------
COPY entrypoint.sh   /root/entrypoint.sh
COPY provisioning.sh /root/provisioning.sh
RUN chmod a+x /root/entrypoint.sh
RUN chmod a+x /root/provisioning.sh


# -----------------------------------------------------------------------------
# Clear
# -----------------------------------------------------------------------------
RUN yum -y clean all && \
    rm -rf /var/cache/yum/*

############################## INSTALLATION END ###############################

# Expose the default MySQL/Mariadb port
EXPOSE 3306

# Start service on run container
ENTRYPOINT ["/root/entrypoint.sh"]

