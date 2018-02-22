#!/bin/bash

set -e
#port=7072

echo ""
echo "-------------------------------------------------------------------------------------------------------------------------"
echo "Extract FHEM config data to /opt/fhem/ if empty:"
echo ""
/root/_cfg/volumedata2.sh write /opt/fhem 
chown -R root:root /opt/fhem
echo ""
#echo "Extract FHEM config data to /opt/fhem/ if empty:"
#echo -en "set ${1} ${2}\nquit\n" | nc -w 5 fhem.sever 7072
#initial update according to https://forum.fhem.de/index.php?topic=44921.0
#echo ""

echo "Starting FHEM:"
echo ""
cd /opt/fhem
perl fhem.pl fhem.cfg | tee /opt/fhem/log/fhem.log 
#&& tail -f /opt/fhem/log/fhem.log
