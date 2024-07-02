#!/bin/bash

echo "- Check that services are running in docker, i.e. ports have listeners"

docker exec -it miad "/status-check.sh"
