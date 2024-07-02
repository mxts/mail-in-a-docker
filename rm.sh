#!/bin/bash

echo "- Removing the docker container and image"

docker container stop miad
docker container rm miad
docker image rm miad-ubuntu
