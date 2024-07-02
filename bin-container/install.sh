#!/bin/bash

if false; then
    # /usr/sbin/named -u bind -g

    # recursive dns at 127.0.0.1
    cp /etc/resolv.conf .
    sed -i "s/nameserver/# nameserver/" resolv.conf
    echo nameserver 127.0.0.1 >>resolv.conf
    cp resolv.conf /etc/resolv.conf

    # start named run as root
    sed -i "s/-u bind/-u root/" /etc/default/named
    cp /named.conf /etc/bind/named.conf
    systemctl enable --now named

    # systemctl status named.service
    # ping google.com
    # exit 0
fi

# exit 0

sudo systemctl enable --now ssh
hostname $1

# enable ipv6 for nsd to start properly
sudo git clone https://github.com/mail-in-a-box/mailinabox

cd mailinabox
git checkout v68

## START: Before install

/home/user-data/before-install.sh

sed -i "s/-u bind /-u root /" /mailinabox/setup/system.sh
sed -i "s/SSH_PORT=/SSH_PORT=22\#/" /mailinabox/setup/system.sh
sed -i "s/rm -f \/etc\/resolv.conf/echo rm -f \/etc\/resolv.conf || true/" /mailinabox/setup/system.sh
sed -i "s/echo \"nameserver 127.0.0.1/\#echo \"nameserver 127.0.0.1/" /mailinabox/setup/system.sh
#sed -i "s/\# Get a/echo \$@; \# Get a/" /mailinabox/setup/functions.sh
sed -i "s/hide_output service \$1 restart/return \#hide_output service \$1 restart/" /mailinabox/setup/functions.sh
sed -i "s/DEBIAN_FRONTEND=noninteractive hide_output apt-get -y/DEBIAN_FRONTEND=noninteractive hide_output apt-get --no-install-recommends -y/" /mailinabox/setup/functions.sh

# Use PHP 8.1
sed -i "s/PHP_VER=8.0/PHP_VER=8.1;DISABLE_FIREWALL=0/" /mailinabox/setup/functions.sh
sed -i "s/php8.0-fpm/php8.1-fpm/" /mailinabox/conf/nginx-top.conf
sed -i "s/php8.0-fpm/php8.1-fpm/" /mailinabox/tools/owncloud-restore.sh
sed -i "s/php8.0-fpm/php8.1-fpm/" /mailinabox/management/backup.py

# disable nextcloud
echo "- Disabling nextcloud installation"
sed -i "s/source setup\/nextcloud.sh/# source setup\/nextcloud.sh/" /mailinabox/setup/start.sh

## END: Before install

# shift nginx ports
# sed -i "s/listen 80;/listen 810;/" /mailinabox/conf/nginx.conf
# sed -i "s/listen 443/listen 4413/" /mailinabox/conf/nginx.conf
# sed -i "s/:80/:810/" /mailinabox/conf/nginx.conf
# sed -i "s/:443/:4413/" /mailinabox/conf/nginx.conf

# adds --nodetach so that spampd runs in the foreground and can fork processes
sed -i "s/--setsid/--setsid --nodetach/" /lib/systemd/system/spampd.service

# insert bunch of services to start to the end of /mailinabox/setup/munin.sh

## with nsd and named
sed -i "s/restart_service munin-node/sed -i \"s\/\^PIDFile=\/\#PIDFile\/\" \/usr\/lib\/systemd\/system\/spampd.service;sed -i \"s\/\^PIDFile=\/\#PIDFile\/\" \/usr\/lib\/systemd\/system\/opendkim.service;sed -i \"s\/-xf\/-xfv\/\" \/lib\/systemd\/system\/fail2ban.service;sed -i \"s\/\^PIDFile=\/\#PIDFile\/\" \/usr\/lib\/systemd\/system\/opendmarc.service; systemctl daemon-reload; systemctl stop named; systemctl enable --now fail2ban postfix postgrey dovecot spampd nginx php8.1-fpm mailinabox munin opendkim opendmarc spamassassin nsd; systemctl start nsd; systemctl enable --now named; systemctl start named spampd; return/" /mailinabox/setup/munin.sh

## without nsd and named
# sed -i "s/restart_service munin-node/sed -i \"s\/\^PIDFile=\/\#PIDFile\/\" \/usr\/lib\/systemd\/system\/spampd.service;sed -i \"s\/\^PIDFile=\/\#PIDFile\/\" \/usr\/lib\/systemd\/system\/opendkim.service;sed -i \"s\/-xf\/-xfv\/\" \/lib\/systemd\/system\/fail2ban.service;sed -i \"s\/\^PIDFile=\/\#PIDFile\/\" \/usr\/lib\/systemd\/system\/opendmarc.service; systemctl daemon-reload; systemctl stop named; systemctl enable --now fail2ban postfix postgrey dovecot spampd nginx php8.1-fpm mailinabox munin opendkim opendmarc spamassassin; systemctl start spampd; return/" /mailinabox/setup/munin.sh

sudo setup/start.sh

## START: After install
/home/user-data/after-install.sh
## END After install

service --status-all
/status-check.sh
