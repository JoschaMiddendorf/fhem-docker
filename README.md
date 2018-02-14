## Docker Container for FHEM House-Automation-System - Full install
This image is a modified version of the second version build 1/2017 of pipp37/fhem_jessie and is debian 8 (jessie) based, includes some stuff and has several perl modules installed. It should run out of the box.

If using host volumes (ie. /opt/fhem) initial data are exctracted from the installation but only if the host directory is empty.

Website: http://www.fhem.de

Fhem forum thread: https://forum.fhem.de/index.php/topic,51190.0.html

### Features
* volume /opt/fhem
* volume /opt/yowsup-config
* Imagemagic
* avrdude - firmware flash
* Python - yowsup (separate volume) for whatsapp client - volume: /opt/yowsup-config
* Open-SSH daemon
* Exposed ports: 2222/SSH, 7072 Fhem-raw, 8083-8085 Fhem Web, 9001 supervisord (** new **)
* supervisord for fhem
* changed running fhem system checked with a pid-controlled script and totaly controlled from supervisord (** new **)
* supervisord for sshd (** new **) 
* cron daemon / at
* NFS client and autofs /net
* ssh root password: fhem!
* USB tools for CUL hardware
* supervisor web-ui at port 9001 (user:admin pass:admin) (** new **)

### Run:
    docker run -d --name fhem --cap-add SYS_ADMIN -p 7072:7072 -p 8083:8083 -p 8084:8084 -p 8085:8085 -p 2222:2222 -p 9001:9001 diggewuff/fhem-docker
   
If NFS mount fails run with `--privileged` switch.

    docker run -d --name fhem --privileged -p 7072:7072 -p 8083:8083 -p 8084:8084 -p 8085:8085 -p 2222:2222  diggewuff/fhem-docker

### Run with volume on host:

    docker run -d --name fhem --cap-add SYS_ADMIN -v /var/fhemdocker/fhem:/opt/fhem -p 7072:7072 -p 8083:8083 -p 8084:8084 -p 8085:8085 -p 2222:2222 -p 9001:9001 diggewuff/fhem-docker


Using  usb  needs to add the device to the run command.  Check usb devices on the host with ` lsusb `.

` lsusb -v | grep -E '\<(Bus|iProduct|bDeviceClass|bDeviceProtocol)' 2>/dev/null `

Add for example: `  --device=/dev/bus/usb/001/002 ` .


### Commands:
##### Running containers:
    docker ps
##### Attach shell to container with:
    docker exec -it ContainerID /bin/bash
##### Stop FHEM inside container
    supervisorctl stop fhem
##### Start FHEM inside container
    supervisorctl start fhem
    
#### GUI FHEM:
    http://ipaddress:8083

#### GUI supervisord:
    http://ipaddress:9001


 
