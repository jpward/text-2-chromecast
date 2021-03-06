#!/bin/bash

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

BASE="`cat ${HERE}/BUILDER | cut -d':' -f1`"
VER="`cat ${HERE}/BUILDER | cut -d':' -f2`"
DIMG="$(docker images | grep ${BASE,,} | head -1 | awk '{print $1":"$2}')"

RUNMODE="-d --restart always"
#RUNMODE="--rm"
docker run \
        --privileged \
        ${RUNMODE} \
        -ti \
        --network host \
        ${DIMG} /bin/bash -c ' \
                              (cd /tmp/ && python3 -m http.server 5001 &) \
                              && (python3 chromecast_server.py & echo $!) > /tmp/PID \
                              && while true; do espeak -w /tmp/wav.wav "$(nc -l -p 22223)" || echo "EEK"; kill -s SIGTERM $(cat /tmp/PID); sleep 0.1; done \
                             '

