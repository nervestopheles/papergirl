#!/bin/bash
set -e

COLOR_GREEN='\033[0;32m'
COLOR_DEFAULT='\033[0m'

# container and pod names
CONTAINER=papergirl-core
POD=${CONTAINER}-pod

IMG=localhost/${CONTAINER}:latest

podman build --tag ${CONTAINER} .

systemctl disable                   \
    container-${CONTAINER}.service  \
    pod-${POD}.service || true
systemctl stop                      \
    container-${CONTAINER}.service  \
    pod-${POD}.service || true

podman pod create     \
    --name ${POD}     \
    --hostname ${POD} \
    -p 8090:8090

podman run                      \
    --pod ${POD}                \
    --name ${CONTAINER}         \
    --cpus 1                    \
    --memory 1gb                \
    --cap-add=net_admin,net_raw \
    -d ${IMG}

podman generate systemd --new --name ${POD} -f
mv -f *.service /etc/systemd/system/

systemctl enable                    \
    container-${CONTAINER}.service  \
    pod-${POD}.service

systemctl start                     \
    container-${CONTAINER}.service  \
    pod-${POD}.service

echo -e "${COLOR_GREEN}${CONTAINER}: done${COLOR_DEFAULT}"
