#!/bin/bash

set -e
#cd /opt/fhem
cd /
port=7072

#echo "Extract FHEM config data to /opt/fhem/ if empty:"
#echo ""
#/root/_cfg/volumedata2.sh write /opt/fhem 
#chown -R root:root /opt/fhem
#echo ""
#echo ""

echo "Starting FHEM:"
echo ""
perl /opt/fhem/fhem.pl /opt/fhem/fhem.cfg | tee /opt/fhem/log/fhem.log

/bin/bash
