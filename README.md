# Docker Container for FHEM House-Automation-System
## Full install with all dependencies
This image of FHEM is based on debian and runs on every possible docker host. The master branch (latest) is currently based on debian jessie and the beta and experimental branches (beta & experimental) are currently running on debian stretch. It has several perl modules installed, however if you are missing any modules packages or features don't hesitate to ask for it by opening an isuue on GitHub. 
https://github.com/JoschaMiddendorf/fhem-docker/issues/new

You can make your entire configuration persitent across updates and restarts by mapping the volume /opt/fhem to a directory of your choise. 
If the maped directory is empty prior to the first atempt to run the container, initial data will be extracted from the install.
Furthermore there are some goodies, predefinitions and helpers in the initial config whitch will make it easy for you to start over.

* Video Tutorials: https://www.youtube.com/channel/UCRDCsZvUg75Bibp9qYbHivw
* Manuals: https://haus-automatisierung.com/
* FHEM Website: http://www.fhem.de
* FHEM Forum: https://forum.fhem.de
___
### Features
* mapable and self initialising volume /opt/fhem
* Exposed ports: 7072 for FHEM-Tellnet and 8083-8089 for FHEM Web, Tablet UI and Webhooks.
* Preinstalled haus-automatisierung.com theme
* Preconfigured nice looking FHEM Web
* Live FHEM log output via docker
* Reliable start script for gracefull restart and shutdown handling without sending kill signals to FHEM
* Docker Healthcheck to check FHEMs first defined FHEMWEB frontend for actual reachability
* Constantly improved and maintained 
* Feature requests and feedback is highly appreciated
___
#### If you appreciate my work and if you use and like these container, consider to make a little donation.

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=L98P3QMZFDHCN)
___
### Run:
    docker run -d --name fhem-docker -p 7072:7072 -p 8083:8083 -p 8084:8084 -p 8085:8085 -p 8086:8086 -p 8087:8087 -p 8088:8088 -p 8089:8089 diggewuff/fhem-docker
___
### Run with mapped volume on host:

    docker run -d --name fhem-docker -v /my/host/directory:/opt/fhem -p 7072:7072 -p 8083:8083 -p 8084:8084 -p 8085:8085 -p 8086:8086 -p 8087:8087 -p 8088:8088 -p 8089:8089 diggewuff/fhem-docker

#### If you are using USB devices, you will need to mapp them to the container via the run command. 

Check for usb devices on the host with  `lsusb`:

    lsusb -v | grep -E '\<(Bus|iProduct|bDeviceClass|bDeviceProtocol)' 2>/dev/null

and mapp them to the container by adding argument like this to the run command:
    
    --device=/dev/bus/usb/001/002

#### Furtermore you can define the following environmental variables to customize the behavior of the container:

Timeout interval, in seconds, before container stopps when FHEM process terminates unexpectedly.

    -e TIMEOUT=10
Your timezone according to POSIX (http://lmgtfy.com/?q=POSIX+timezones), to configute the container to have your local time.

    -e TZ=Europe/Berlin
___
### Advices:
#### Keep the folowing lines in your config files or add them if you are migrating from an existing config.

    attr global logfile /opt/fhem//log/fhem-%Y-%m.log
    attr global modpath /opt/fhem/
    attr global nofork 0
    attr global pidfilename /opt/fhem/log/fhem.pid
    attr global updateInBackground 1
    define telnetPort telnet 7072 global
#### And furthermore    
Make shure do always use absolout paths in your fhem.cfg beginning with /opt/fhem/ not with ./ !
___
### Commands:
##### Running containers:
    docker ps
##### Attach shell to container with:
    docker exec -it fhem-docker /bin/bash
##### View log of container with:
    docker logs -f fhem-docker
    
#### GUI FHEM:
    http://ipaddress:8083
___
[![Donate](https://img.shields.io/badge/Donate-PayPal-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=L98P3QMZFDHCN)
___
[![](https://images.microbadger.com/badges/version/diggewuff/fhem-docker.svg)](https://microbadger.com/images/diggewuff/fhem-docker "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/diggewuff/fhem-docker.svg)](https://microbadger.com/images/diggewuff/fhem-docker "Get your own image badge on microbadger.com")

[![](https://images.microbadger.com/badges/version/diggewuff/fhem-docker:beta.svg)](https://microbadger.com/images/diggewuff/fhem-docker:beta "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/diggewuff/fhem-docker:beta.svg)](https://microbadger.com/images/diggewuff/fhem-docker:beta "Get your own image badge on microbadger.com")

[![](https://images.microbadger.com/badges/version/diggewuff/fhem-docker:experimental.svg)](https://microbadger.com/images/diggewuff/fhem-docker:experimental "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/diggewuff/fhem-docker:experimental.svg)](https://microbadger.com/images/diggewuff/fhem-docker:experimental "Get your own image badge on microbadger.com")
