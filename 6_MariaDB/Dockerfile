###############################################################################
# Dockerfile to build Mariadb container images
# Based on Ubuntu 18.04
###############################################################################

# Set the base image to Ubuntu 18.04
FROM ubuntu:bionic

# File Author / Maintainer
MAINTAINER hyeongchae@gmail.com 

LABEL vendor="MySQL Korea User Group" \
      description="MariaDB Server on Ubuntu Disco" \
      version="10.4"

RUN sed -i 's/archive\.ubuntu/kr\.archive\.ubuntu/g' /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y software-properties-common && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 && \ 
    add-apt-repository 'deb [arch=amd64] http://mirror.yongbok.net/mariadb/repo/10.4/ubuntu bionic main' && \
    apt-get install -y apt-utils curl tzdata vim unzip iputils-ping lsb-core dnsmasq jq wget mysql-utilities 

# -----------------------------------------------------------------------------
# Install MariaDB Server
# -----------------------------------------------------------------------------
RUN apt-get install -y mariadb-server mariadb-client

COPY 50-server.cnf  /etc/mysql/mariadb.conf.d/50-server.cnf 
RUN chown root:root /etc/mysql/mariadb.conf.d/50-server.cnf

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
# Install pmm-client, pt-xtrabackup
# -----------------------------------------------------------------------------
ADD https://repo.percona.com/apt/percona-release_latest.generic_all.deb /root/
RUN dpkg -i /root/percona-release_latest.generic_all.deb && \
    percona-release enable-only ps-80 release && \
    percona-release enable tools release && \
    apt-get update -y && \
    apt-get install -y pmm-client percona-xtrabackup 

# -----------------------------------------------------------------------------
# Install dnsmasq
# -----------------------------------------------------------------------------
COPY 10-consul /etc/dnsmasq.d

# -----------------------------------------------------------------------------
# Copy script utility
# -----------------------------------------------------------------------------
COPY entrypoint.sh /root/entrypoint.sh
COPY provisioning.sh /root/provisioning.sh
RUN chmod a+x /root/entrypoint.sh
RUN chmod a+x /root/provisioning.sh

# -----------------------------------------------------------------------------
# Clear
# -----------------------------------------------------------------------------
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

############################## INSTALLATION END ###############################

# Expose the default http port
EXPOSE 3306

# Start service on run container
ENTRYPOINT ["/root/entrypoint.sh"]
