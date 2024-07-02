#!/bin/bash

echo "# Install nsd and bind9, patch config and flush DNS"
echo "- Almost the entirety of this file was extracted from MIAB as-is"

function get_default_privateip {
    # Return the IP address of the network interface connected
    # to the Internet.
    #
    # Pass '4' or '6' as an argument to this function to specify
    # what type of address to get (IPv4, IPv6).
    #
    # We used to use `hostname -I` and then filter for either
    # IPv4 or IPv6 addresses. However if there are multiple
    # network interfaces on the machine, not all may be for
    # reaching the Internet.
    #
    # Instead use `ip route get` which asks the kernel to use
    # the system's routes to select which interface would be
    # used to reach a public address. We'll use 8.8.8.8 as
    # the destination. It happens to be Google Public DNS, but
    # no connection is made. We're just seeing how the box
    # would connect to it. There many be multiple IP addresses
    # assigned to an interface. `ip route get` reports the
    # preferred. That's good enough for us. See issue #121.
    #
    # With IPv6, the best route may be via an interface that
    # only has a link-local address (fe80::*). These addresses
    # are only unique to an interface and so need an explicit
    # interface specification in order to use them with bind().
    # In these cases, we append "%interface" to the address.
    # See the Notes section in the man page for getaddrinfo and
    # https://discourse.mailinabox.email/t/update-broke-mailinabox/34/9.
    #
    # Also see ae67409603c49b7fa73c227449264ddd10aae6a9 and
    # issue #3 for why/how we originally added IPv6.

    target=8.8.8.8

    # For the IPv6 route, use the corresponding IPv6 address
    # of Google Public DNS. Again, it doesn't matter so long
    # as it's an address on the public Internet.
    if [ "$1" == "6" ]; then target=2001:4860:4860::8888; fi

    # Get the route information.
    route=$(ip -"$1" -o route get $target 2>/dev/null | grep -v unreachable)

    # Parse the address out of the route information.
    address=$(echo "$route" | sed "s/.* src \([^ ]*\).*/\1/")

    if [[ "$1" == "6" && $address == fe80:* ]]; then
        # For IPv6 link-local addresses, parse the interface out
        # of the route information and append it with a '%'.
        interface=$(echo "$route" | sed "s/.* dev \([^ ]*\).*/\1/")
        address=$address%$interface
    fi

    echo "$address"
}

apt -y install \
    bind9 \
    nsd

cat >/etc/nsd/nsd.conf <<'EOF'
# Do not edit. Overwritten by Mail-in-a-Docker setup, based on Mail-in-a-Box setup.
server:
  hide-version: yes
  logfile: "/var/log/nsd.log"

  # identify the server (CH TXT ID.SERVER entry).
  identity: ""

  # The directory for zonefile: files.
  zonesdir: "/etc/nsd/zones"

  # Allows NSD to bind to IP addresses that are not (yet) added to the
  # network interface. This allows nsd to start even if the network stack
  # isn't fully ready, which apparently happens in some cases.
  # See https://www.nlnetlabs.nl/projects/nsd/nsd.conf.5.html.
  ip-transparent: yes

EOF

PRIVATE_IP=$(get_default_privateip 4)
PRIVATE_IPV6=$(get_default_privateip 6)

for ip in $PRIVATE_IP $PRIVATE_IPV6; do
    echo "  ip-address: $ip" >>/etc/nsd/nsd.conf
done
echo 'include: "/etc/nsd/nsd.conf.d/*.conf"' >>/etc/nsd/nsd.conf

systemctl stop nsd
systemctl stop named
systemctl enable --now nsd
systemctl enable --now named

/usr/sbin/rndc flush
