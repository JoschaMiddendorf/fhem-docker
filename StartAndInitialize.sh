#!/bin/bash
##################################################################################################
##
##	Start and intitialization script for fhem-docker
##	Copyright (c) 2018 Joscha Middendorf
##
##	Before mounting a volume to the container, this script comresses the content 
##	of a provided configuration directory to /root/_config.
##	usage:	./StartAndInitialize.sh Arg1=initialize Arg2=/abs/path/to/directory/
##
##	After mounting a volume to the container, this script extracts the content 
##	of the previously compressed configuration directory back to a provided directory,
##	if the directory is empty.
##	usage:	./StartAndInitialize.sh Arg1=extract Arg2=/abs/path/to/directory/
##
##################################################################################################

### Functions to start FHEM ###

function StartFHEM {
	echo ''
	echo 'Starting FHEM:'
	echo ''
	cd /opt/fhem
	perl fhem.pl fhem.cfg | tee /opt/fhem/log/fhem.log
}
function StartFHEMandUpdate {
	echo ''
	echo '!  Almost ready... You are about to start FHEM for the first time.'
	echo '!  Pleast connect to FHEM via http://YourLocalIP:8083 '
	echo '!  and execute the command "update" (without the "") first before you do anything else."'
	echo '!  As soon as the update is complete, execute "shutdown restart" and have fun!'
	echo ''
	echo Starting FHEM:
	echo ''
	cd /opt/fhem
	perl fhem.pl fhem.cfg | tee /opt/fhem/log/fhem.log
}

### Start of Script ###

echo ''
echo '-------------------------------------------------------------------------------------------------------------------------'
echo 'Extract FHEM config data to /opt/fhem/ if empty:'
echo ''

if [ -z $2 ]; then
    echo 'Error: Not enough arguments provided, please provide Arg1=initialize/extract and Arg2=/abs/path/to/directory/'
    exit 1
fi

PACKAGEDIR=/root/_config
test -e $PACKAGEDIR || mkdir -p $PACKAGEDIR 

case $1 in
	initialize)
		## check if $2 is a extsting directory
		if  [ -d  $2 ]; then  
			PACKAGE=$PACKAGEDIR/`echo $2 | tr '[/]' '-'`.tgz
			tar -fcz $PACKAGE $2018
			echo "Created package $PACKAGE from $2."
		fi
		;;
	extract)
		## check if $PACKAGE was extracted before
		PACKAGE=$PACKAGEDIR/`echo $2 | tr '[/]' '-'`.tgz
		if [ -e $PACKAGE.extracted ]; then
			echo "The package $PACKAGE was already extracted before, no extraction processed!"
			StartFHEM
			exit
		fi
		
		# check if directory $2 is empty
		if 	[ "$(ls -A $2)" ]; then
			echo "Directory $2 isn't empty, no extraction processed!"
			StartFHEM
			exit
		else 
			# check if $PACKAGE exists
			if [ -e $PACKAGE ]; then
				tar -xzkf $PACKAGE -C / 
				touch $PACKAGE.extracted
				echo "Extracted package $PACKAGE to $2"
				StartFHEMandUpdate
			fi
		fi	
		;;
	*)
		echo 'Error: Wrong arguments provided, please provide Arg1=initialize/extract and Arg2=/abs/path/to/directory/'
		exit 1
	;;
esac