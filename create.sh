#!/bin/bash

# systemctl disable --now postfix exit
# docker system prune -a

echo "- Up the container, install and start MIAB"

# TODO: check that all ports are available here

chmod +x ./bin-container/install.sh
chmod +x ./bin-container/status-check.sh

docker container stop miad
docker container rm miad

# build the container, but can't start due to 53 blocked
./up.sh
# service systemd-resolved stop
# try again as 53 is now unblocked
# ./up.sh
docker exec -it miad "./install.sh" "$1"

# service systemd-resolved restart
