#!/bin/bash
# encoding: UTF-8
set -e

echo '[Entrypoint] dnsmasq test.'
dnsmasq --test

echo '[Entrypoint] dnsmasq start.'
dnsmasq --user=root -8 /var/log/dnsmasq.log

echo '[Entrypoint] Validated consul.'
consul validate -quiet /etc/consul.d

echo '[Entrypoint] Start consul agent.'
consul agent -config-file=/etc/consul.d/consul_client.json &

echo '[Entrypoint] Start vault dev server.'
vault server -dev -dev-root-token-id="vault" -dev-listen-address="0.0.0.0:8200"
