###############################################################################
# Dockerfile to build Orchestrator container images
# Based on Centos 7
###############################################################################

# Set the base image to Centos 7
FROM centos:7

# File Author / Maintainer
MAINTAINER hyeongchae@gmail.com 

LABEL vendor="MySQL Korea User Group" \
      description="GitHub's Orchestrator on Centos 7" \
      version="3.1.2"

# Update the repository sources list
RUN yum -y --setopt=tsflags=nodocs update

# Install additional repository and add repository key
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

###############################################################################
# BEGIN INSTALLATION
###############################################################################

# -----------------------------------------------------------------------------
# Install Orchestrator
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install wget unzip dnsmasq bind-utils && \
yum -y --setopt=tsflags=nodocs install https://github.com/github/orchestrator/releases/download/v3.1.2/orchestrator-3.1.2-1.x86_64.rpm && \
yum -y --setopt=tsflags=nodocs install https://github.com/github/orchestrator/releases/download/v3.1.2/orchestrator-cli-3.1.2-1.x86_64.rpm


COPY orchestrator.conf.json /etc/orchestrator.conf.json
RUN chown root:root /etc/orchestrator.conf.json && \
    chmod a+x /etc/orchestrator.conf.json

# -----------------------------------------------------------------------------
# Install consul
# -----------------------------------------------------------------------------
ADD https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip /root/
RUN unzip /root/consul_1.6.1_linux_amd64.zip -d /root/ && \
    rm -f /root/consul_1.6.1_linux_amd64.zip && \
    mv /root/consul /usr/local/bin/ && \
    mkdir -p /etc/consul.d/

COPY consul_client.json /etc/consul.d/consul_client.json

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
EXPOSE 3000

# Start service on run container
ENTRYPOINT ["/root/entrypoint.sh"]
