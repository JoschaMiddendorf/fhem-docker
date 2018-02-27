#!/bin/bash

CONFIG_FILE=/opt/fhem/fhem.cfg
if [ -f "${CONFIG_FILE}" ]; then
        FHEMWEB_PORT=$(^grep -m 1 "define .* FHEMWEB .* global$" ${CONFIG_FILE} | awk '{print $4}')
        FHEMWEB_NAME=$(^grep -m 1 "define .* FHEMWEB .* global$" ${CONFIG_FILE} | awk '{print $2}')
fi

grep -q "^attr $FHEMWEB_NAME HTTPS 1$" ${CONFIG_FILE} && HTTP_S='https' || HTTP_S='http'
PORT=${FHEMWEB_PORT:-8083}

curl -ks --fail "$HTTP_S"://localhost:"${PORT}" && exit 0 || exit 1
