#!/bin/bash

CONFIG_FILE=/opt/fhem/fhem.cfg
if [ -f "${CONFIG_FILE}" ]; then
    FHEM_PORT=$(grep "^FHEMWEB" ${CONFIG_FILE} | cut -d' ' -f4)
fi
PORT=${FHEM_PORT:-8083}

curl -kILs --fail http://localhost:"${PORT}"
