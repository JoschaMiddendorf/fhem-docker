#!/bin/bash
##################################################################################################
##
##      Healthcheck script for fhem-docker
##      Copyright (c) 2018 Joscha Middendorf
##
##      This script scanns fhem.cfg for the first FHEMWEB device and determines
##      it's PORT and NAME, afterwards it determines if the HTTPS attribute for the
##      device is set to 1.
##
##      Now that it knows on witch PORT FHEM is running and if FHEM runs on HTTP or HTTPS
##      it starts a corisponding curl request via localhost and reports the reachability
##      via exit code 0/1 to set docker health status to healthy/unhealthy.
##
##################################################################################################

CONFIG_FILE=/opt/fhem/fhem.cfg
if [ -f "${CONFIG_FILE}" ]; then
        FHEMWEB_PORT=$(grep -m 1 "define .* FHEMWEB .* global$" ${CONFIG_FILE} | awk '{print $4}')
        FHEMWEB_NAME=$(grep -m 1 "define .* FHEMWEB .* global$" ${CONFIG_FILE} | awk '{print $2}')
fi

grep -q "^attr $FHEMWEB_NAME HTTPS 1$" ${CONFIG_FILE} && HTTP_S='https' || HTTP_S='http'

PORT=${FHEMWEB_PORT:-8083}

test -z "$HEALTHCHECKCREDENTIALS" && CREDENTIALS="" || CREDENTIALS="--user $HEALTHCHECKCREDENTIALS"

curl -ks $CREDENTIALS --fail "$HTTP_S"://localhost:"${PORT}" && exit 0 || exit 1
