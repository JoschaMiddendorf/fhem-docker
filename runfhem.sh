#! /usr/bin/env bash
# Runs FHEM in foregroud for supervisord

set -eu


pidfile="/var/run/fhem/fhem.pid"
cd /opt/fhem
# command=/usr/sbin/your-daemon
command=perl

# Proxy signals
function kill_app(){
    kill $(cat $pidfile)
    exit 0 # exit okay
}
trap "kill_app" SIGINT SIGTERM

# Launch daemon
$command fhem.pl fhem.cfg
sleep 2

# Loop while the pidfile and the process exist
while [ -f $pidfile ] && kill -0 $(cat $pidfile) ; do
    sleep 0.5
done
exit 1000 # exit unexpected
