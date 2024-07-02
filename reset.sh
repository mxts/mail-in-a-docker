#!/bin/bash

echo "- Reset our scripts"
docker container stop miad
systemctl restart systemd-resolved.service
git pull
git reset --hard
