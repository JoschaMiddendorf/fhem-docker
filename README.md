## Docker Container for FHEM House-Automation-System - Full install with all dependencies
This image of FHEM is debian jessie based and runns out of the box. It has several perl modules installed. However if you are missing any modules packages or features don't hesitate to ask for it by opening an isuue on github https://github.com/JoschaMiddendorf/fhem-docker/issues/new. 

You can make your entire configuration persitent across updates and restarts by mapping the volume /opt/fhem to a directory of your choise. 
If the maped directory is empty prior to the first atempt to run the container, initial data will be extracted from the install.
Furthermore there are some goodies, predefinitions and helpers in the initial config whitch will make it easy for you to start over.

* Video Tutorials: https://www.youtube.com/channel/UCRDCsZvUg75Bibp9qYbHivw
* Manuals: https://haus-automatisierung.com/
* FHEM Website: http://www.fhem.de
* FHEM Forum: https://forum.fhem.de

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

#### If you appreciate my work and if you use and like these container, consider to make a little donation.

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=L98P3QMZFDHCN)


### Run:
    docker run -d --name FHEM -p 7072:7072 -p 8083:8083 -p 8084:8084 -p 8085:8085 -p 8086:8086 -p 8087:8087 -p 8088:8088 -p 8089:8089 diggewuff/fhem-docker


### Run with mapped volume on host:

    docker run -d --name FHEM -v /my/host/directory:/opt/fhem -p 7072:7072 -p 8083:8083 -p 8084:8084 -p 8085:8085 -p 8086:8086 -p 8087:8087 -p 8088:8088 -p 8089:8089 diggewuff/fhem-docker


If you are using USB devices, you will need to mapp them to the container via the run command. 
Check for usb devices on the host with  `lsusb`.

    lsusb -v | grep -E '\<(Bus|iProduct|bDeviceClass|bDeviceProtocol)' 2>/dev/null

and mapp them to the container by adding argument like this to the run command:
    
    --device=/dev/bus/usb/001/002

### Advices:
#### Keep the folowing lines in your config files or add them if you are migrating from an existing config.
    
    attr global logfile ./log/fhem-%Y-%m.log
    attr global nofork 0
    attr global pidfilename /opt/fhem/log/fhem.pid
    attr global updateInBackground 1
    define telnetPort telnet 7072 global

### Commands:
##### Running containers:
    docker ps
##### Attach shell to container with:
    docker exec -it FHEM /bin/bash
##### View log of container with:
    docker logs -f FHEM
    
#### GUI FHEM:
    http://ipaddress:8083
