#!/bin/bash

echo "# Patch SNIProxy config and service"

echo DAEMON_ARGS=\"-f\" >>/etc/default/sniproxy

cp ./sniproxy.conf.example /etc/sniproxy.conf

systemctl stop sniproxy
systemctl enable --now sniproxy

/usr/sbin/rndc flush
