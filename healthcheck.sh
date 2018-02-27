#!/bin/bash

CONFIG_FILE=/opt/fhem/fhem.cfg
if [ -f "${CONFIG_FILE}" ]; then
        FHEM_PORT=$(grep -m 1 "define .* FHEMWEB .* global" ${CONFIG_FILE} | awk '{print $4}')
fi
PORT=${FHEM_PORT:-8083}

curl -ks --fail http://localhost:"${PORT}" && exit 0 || exit 1
