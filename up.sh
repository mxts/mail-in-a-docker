#!/bin/bash

# systemctl disable --now postfix exit
# docker system prune -a

echo "- Up the container"

time docker compose up -d --remove-orphans
