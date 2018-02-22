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
#echo "Extract FHEM config data to /opt/fhem/ if empty:"
#echo -en "set ${1} ${2}\nquit\n" | nc -w 5 fhem.sever 7072
#initial update according to https://forum.fhem.de/index.php?topic=44921.0
#echo ""

echo "Starting FHEM:"
echo ""
cd /opt/fhem
perl fhem.pl fhem.cfg | tee /opt/fhem/log/fhem.log 
#&& tail -f /opt/fhem/log/fhem.log




#!/bin/bash
##############################################################################
# cfg script for volumedata
# (c) armin@pipp.at 01/2017
#
# This tool extracts files from the initial config process from a tar file.
# If files exist, no one are overwritten!
#
# usage:   ./volumedata2.sh <mode <dir
# EXAMPLE: ./volumedata2.sh write /var/www
#           modes: create = makes tgz file
#                   write = extract from tgz
###########################################################################


if [ -z $2 ]; then
    echo "Error: Missing mode or dir as parameter! IE: create /var/www " 
    exit
fi

# echo "The script you are running has basename `basename $0`, dirname `dirname $0`"

DIR=`dirname $0`
TGZDIR=/_cfg
test -e $TGZDIR || mkdir -p $TGZDIR 

# echo CFGdir=$DIR
# echo TGZdir=$TGZDIR

case $1 in
	create)
		# echo create $2
		# if  dir exist
		if  [ -d  $2 ]; then  
			TGZ=$TGZDIR/`echo $2 | sed -r 's/\//_/g'`.tgz
			echo create $TGZ from $2
			tar -czf $TGZ $2
		fi
		;;
	write)
		# echo write $2
		TGZ=$TGZDIR/`echo $2 | sed -r 's/\//_/g'`.tgz
		
		if [ -e $TGZ.firstrun ]; then
			 echo firstrun $2 already done, exit
			exit
		fi
		
		# extract only if dir not empty
		if 	[ "$(ls -A $2)" ]; then
			echo "$2 not empty - no extraction, exit!"
			exit
			else 
			if [ -e $TGZ ]; then
				# -C /destdirroot  -k, --keep-old-files
				# -k do not overwrite existsing files
				echo extract $TGZ to $2 
				tar -xzkf $TGZ -C / 
				touch $TGZ.firstrun
			fi
		fi	
		;;
	*)
	echo wrong parameter
	exit 1
	;;
esac
