#!/bin/bash

docker rm -f nark

docker run -d \
    --name nark \
    -p 5789:80 \
    -v "$(pwd)"/config:/app/Config \
    -v "$(pwd)"/logfile:/app/logfile \
    -it --privileged=true \
    nolanhzy/nark:latest
