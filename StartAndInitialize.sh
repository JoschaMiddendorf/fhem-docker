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
	LOGFILE=/opt/fhem/log/fhem-%Y-%m.log
	PIDFILE=/opt/fhem/log/fhem.pid 
	SLEEPINTERVAL=0.2
	
	## Function to print FHEM log in incremental steps to the docker log.
	OLDLINES=$(wc -l < "$(date +"$LOGFILE")")
	NEWLINES=$OLDLINES
	FOUND=false

	function PrintNewLines {
        	NEWLINES=$(wc -l < "$(date +"$LOGFILE")")
        	(( OLDLINES <= NEWLINES )) && LINES=$(( NEWLINES - OLDLINES )) || LINES=$NEWLINES
        	tail -n "$LINES" "$(date +"$LOGFILE")"
        	test ! -z "$1" && grep -q "$1" <(tail -n "$LINES" "$(date +"$LOGFILE")") && FOUND=true || FOUND=false
        	OLDLINES=$NEWLINES
	}

	#until $FOUND; do
        #	sleep $SLEEPINTERVAL
        #	PrintNewLines "Server shutdown"
	#done
	
	## Docker stop sinal handler
	function StopFHEM {
		echo
		echo 'SIGTERM signal received, sending "shutdown" command to FHEM!'
		echo
		PID=$(<"$PIDFILE")
		perl /opt/fhem/fhem.pl 7072 shutdown
		echo 'Waiting for FHEM process to terminate before stopping container:'
		echo
		until $FOUND; do					## Wait for FHEM to shutdown
			sleep $SLEEPINTERVAL
        		PrintNewLines "Server shutdown"
		done
		while ( kill -0 "$PID" 2> /dev/null ); do		## Wait for FHEM to end process
			sleep $SLEEPINTERVAL
		done
		PrintNewLines
		echo
		echo 'FHEM process terminated, stopping container. Bye!'
		exit 0
	}
	
	## Start FHEM
	echo
	echo 'Starting FHEM:'
	echo
	trap "StopFHEM" SIGTERM
	perl /opt/fhem/fhem.pl /opt/fhem/fhem.cfg
	until $FOUND; do										## Wait for FHEM to start up
		sleep $SLEEPINTERVAL
        	PrintNewLines "Server started"
	done
	#grep -q "Server started" <(tail -f -n0 "$(date +"$LOGFILE")")					## Wait for FHEM to start up
	PrintNewLines
	
	## Evetually update FHEM
	if $UPDATE; then
		echo
		echo 'Performing initial update of FHEM, this may take a minute...'
		echo
		perl /opt/fhem/fhem.pl 7072 update > /dev/null
		until $FOUND; do									## Wait for update to finish
			sleep $SLEEPINTERVAL
        		PrintNewLines "update finished"
		done
		#grep -q "update finished" <(tail -f -n5 "$(date +"$LOGFILE")")				## Wait for update to finish
		PrintNewLines
		echo
		echo 'Restarting FHEM after initial update...'
		echo
		perl /opt/fhem/fhem.pl 7072 "shutdown restart"
		until $FOUND; do									## Wait for FHEM to start up
			sleep $SLEEPINTERVAL
        		PrintNewLines "Server started"
		done
		#grep -q "Server started" <(tail -f -n0 "$(date +"$LOGFILE")")				## Wait for FHEM to start up
		PrintNewLines
		echo
		echo 'FHEM updated and restarted!'
		echo
		echo 'FHEM is up and running now:'
		echo
	fi

	## Monitor FHEM during runtime
	while true; do
		if [ ! -f $PIDFILE ] || ! kill -0 "$(<"$PIDFILE")"; then					## FHEM is running
			COUNTDOWN=10
			echo
			echo "FHEM process terminated unexpectedly, waiting for $COUNTDOWN seconds before stopping container..."
			while ( [ ! -f $PIDFILE ] || ! kill -0 "$(<"$PIDFILE")" ) && [ $COUNTDOWN -gt 0 ]; do	## FHEM exited unexpectedly
				echo "waiting - $COUNTDOWN"
				(( COUNTDOWN-- ))
				sleep 1
			done
			if [ ! -f $PIDFILE ] || ! kill -0 "$(<"$PIDFILE")"; then				## FHEM didn't reappeared
				echo '0 - Stopping Container. Bye!'
				exit 1
			else											## FHEM reappeared
				echo 'FHEM process reappeared, kept container alive!'
			fi
			echo
			echo 'FHEM is up and running again:'
			echo
		fi
		PrintNewLines											## Printing log lines in intervalls
		sleep $SLEEPINTERVAL
	done
}


### Start of Script ###

echo 
echo '-------------------------------------------------------------------------------------------------------------------------'
if [ -z "$2" ]; then
    echo 'Error: Not enough arguments provided, please provide Arg1=initialize/extract and Arg2=/abs/path/to/directory/'
    exit 1
fi

PACKAGEDIR=/root/_config
test -e $PACKAGEDIR || mkdir -p $PACKAGEDIR 

case $1 in
	initialize)
		echo 'Creating package of /opt/fhem/:'
		echo 
		## check if $2 is a extsting directory
		if  [ -d  "$2" ]; then  
			PACKAGE=$PACKAGEDIR/$(echo "$2" | tr '/' '-').tgz
			tar -czf "$PACKAGE" "$2"
			echo "Created package $PACKAGE from $2."
		fi
		;;
	extract)
		echo 'Extracting config data to /opt/fhem/ if empty:'
		echo 
		## check if $PACKAGE was extracted before
		#PACKAGE=$PACKAGEDIR/$(echo "$2" | tr '/' '-').tgz
		#if [ -e "$PACKAGE".extracted ]; then
		#	echo "The package $PACKAGE was already extracted before, no extraction processed!"
		#	UPDATE=false
		#	StartFHEM
		#fi
		
		# check if directory $2 is empty
		if 	[ "$(ls -A "$2")" ]; then
			echo "Directory $2 isn't empty, no extraction processed!"
			UPDATE=false
			StartFHEM
		else 
			# check if $PACKAGE exists
			if [ -e "$PACKAGE" ]; then
				echo "Directory $2 is empty, extracting config now..."
				tar -xzkf "$PACKAGE" -C / 
				#touch "$PACKAGE".extracted
				echo "Extracted package $PACKAGE to $2 to initialize the configuration directory."
				UPDATE=true 
				StartFHEM
			fi
		fi	
		;;
	*)
		echo 'Error: Wrong arguments provided, please provide Arg1=initialize/extract and Arg2=/abs/path/to/directory/'
		exit 1
	;;
esac
