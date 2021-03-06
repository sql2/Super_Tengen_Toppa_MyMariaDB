###############################################################################
# Dockerfile to build ProxySQL container images
# Based on Centos 7
###############################################################################

# Set the base image to Centos 7
FROM centos:7

# File Author / Maintainer
MAINTAINER hyeongchae@gmail.com 

LABEL vendor="hyeongchae" \
      description="ProxySQL on Centos 7" \
      version="2.0.10"

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
RUN yum -y --setopt=tsflags=nodocs install which wget unzip sysvinit-tools initscripts dnsmasq

ADD https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 /usr/local/bin/
RUN chmod +x /usr/local/bin/jq-linux64 && \
		mv /usr/local/bin/jq-linux64 /usr/local/bin/jq

# -----------------------------------------------------------------------------
# Install the Percona repository package
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install https://repo.percona.com/yum/percona-release-latest.noarch.rpm 
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Percona
RUN percona-release setup ps80

# -----------------------------------------------------------------------------
# Install ProxySQL, PMM client, MySQL client 
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install proxysql2 pmm-client percona-server-client 
COPY proxysql.cnf /etc/proxysql.cnf

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
# Install dnsmasq
# -----------------------------------------------------------------------------
COPY 10-consul /etc/dnsmasq.d

# -----------------------------------------------------------------------------
# Copy script utility
# -----------------------------------------------------------------------------
COPY entrypoint.sh /root/entrypoint.sh
COPY handler.sh /root/handler.sh
RUN chmod a+x /root/entrypoint.sh
RUN chmod a+x /root/handler.sh
RUN touch /root/handler.log

# -----------------------------------------------------------------------------
# Clear
# -----------------------------------------------------------------------------
RUN yum -y clean all && \
    rm -rf /var/cache/yum/*
############################## INSTALLATION END ###############################

# Set the working directory to /var/www
WORKDIR /root

# Expose the default http port
EXPOSE 3306 6032

# Start service on run container
ENTRYPOINT ["/root/entrypoint.sh"]
