#!/bin/bash
set -e

# container and pod names
CONTAINER=papergirl-core
POD=${CONTAINER}-pod

IMG=localhost/${CONTAINER}:latest
VOLUME=papergirl-core-data

PORT='8090'

buildah bud --layers --tag ${CONTAINER} .

systemctl disable                   \
    container-${CONTAINER}.service  \
    pod-${POD}.service || true
systemctl stop                      \
    container-${CONTAINER}.service  \
    pod-${POD}.service || true

podman volume create  \
    --driver local    \
    ${VOLUME} || true

podman pod create     \
    --name ${POD}     \
    --hostname ${POD} \
    -p ${PORT}:${PORT}

podman run                      \
    --pod ${POD}                \
    --name ${CONTAINER}         \
    --cpus 1                    \
    --memory 1gb                \
    --cap-add=net_admin,net_raw \
    -v ${VOLUME}:/mnt:rw        \
    -e PORT=${PORT}                                 \
    -e BIND='0.0.0.0'                               \
    -e MODE='production'                            \
    -e RAW_OUTPUT='/mnt/raw_output.json'            \
    -e FORMAT_OUTPUT='/mnt/data.json'               \
    -e SUBSCRIBERS_LIST='/mnt/subscribers_ids.csv'  \
    -d ${IMG}

podman generate systemd --new --name ${POD} -f
mv -f *.service /etc/systemd/system/

systemctl enable                    \
    container-${CONTAINER}.service  \
    pod-${POD}.service

systemctl start                     \
    container-${CONTAINER}.service  \
    pod-${POD}.service

# notification of end.
COLOR_GREEN='\033[0;32m'
COLOR_DEFAULT='\033[0m'

echo -e "${COLOR_GREEN}${CONTAINER}: done${COLOR_DEFAULT}"
