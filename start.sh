#!/bin/bash

set -e
port=7072

echo ""
echo "-------------------------------------------------------------------------------------------------------------------------"
echo "Extract FHEM config data to /opt/fhem/ if empty:"
echo ""
/root/_cfg/volumedata2.sh write /opt/fhem 
chown -R root:root /opt/fhem
echo ""
echo ""

echo "Starting FHEM:"
echo ""
cd /opt/fhem
perl fhem.pl fhem.cfg | tee /opt/fhem/log/fhem.log 
#&& tail -f /opt/fhem/log/fhem.log
