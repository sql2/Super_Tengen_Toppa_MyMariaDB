###############################################################################
# Dockerfile to build Vault container images
# Based on Centos 7
###############################################################################

# Set the base image to Centos 7
FROM centos:7

# File Author / Maintainer
MAINTAINER hyeongchae@gmail.com 

LABEL vendor="MySQL Korea User Group" \
      description="HashiCorp's Vault on Centos 7" \
      version="1.4.1"

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
RUN yum -y --setopt=tsflags=nodocs install unzip dnsmasq bind-utils

# -----------------------------------------------------------------------------
# Install consul
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

# -----------------------------------------------------------------------------
# Install dnsmasq
# -----------------------------------------------------------------------------
COPY 10-consul /etc/dnsmasq.d

# -----------------------------------------------------------------------------
# Copy script utility
# -----------------------------------------------------------------------------
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod a+x /root/entrypoint.sh

# -----------------------------------------------------------------------------
# Clear
# -----------------------------------------------------------------------------
RUN yum -y clean all && \
    rm -rf /var/cache/yum/*
############################## INSTALLATION END ###############################

# Set the working directory to /var/www
WORKDIR /root

# Expose the default http port
EXPOSE 8200 8201 

# Start service on run container
ENTRYPOINT ["/root/entrypoint.sh"]
