# Modifiziet von Joscha Middendorf auf basis von pipp37/fhem_jessie 
# Copyright (c) 2018 Joscha Middendorf
# Copyright (c) 2016 Armin Pipp
# Changes:
# * added volumedata2.sh - extracts  data from a tgz when using empty host volumes
# * added superivsord config for fhem running foreground 
# * supervisor web at port 9001 export
# * added service sshd  to supervisord

FROM debian:jessie
MAINTAINER Joscha Middendorf <joscha.middendorf@me.com>

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
#mod
ENV FHEM_VERSION 5.8

#mod # Install dependencies
RUN apt-get update && apt-get upgrade -y --force-yes && apt-get install -y --force-yes --no-install-recommends apt-utils
RUN apt-get -y --force-yes install \
perl \
wget \
git \
apt-transport-https \
dfu-programmer \
build-essential \
snmpd \
snmp \
vim \
usbutils \
sqlite3 \
nano \
make \
gcc \
g++ \
libavahi-compat-libdnssd-dev \
sudo \
nodejs \
etherwake \
mc \
vim \
htop \
snmp \
lsof \
libssl-dev \
telnet-ssl \
imagemagick \
dialog \
curl \
usbutils \
mysql-client \
&& apt-get clean

#bluetooth \
#bluez-hcidump \
#bluez \
#blueman \

#Speedtest-CLI
RUN cd /usr/local/bin \
 && wget -O speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py \
 && chmod +x speedtest-cli

# Firmware flash
RUN  apt-get -y --force-yes install  avrdude git-core gcc-avr avr-libc \
&& apt-get clean

#mod # Install perl packages
RUN apt-get -y --force-yes install \
libavahi-compat-libdnssd-dev \
libalgorithm-merge-perl \
libclass-dbi-mysql-perl \
libclass-isa-perl \
libcommon-sense-perl \
libdatetime-format-strptime-perl \
libdbi-perl \
libdevice-serialport-perl \
libdpkg-perl \
liberror-perl \
libfile-copy-recursive-perl \
libfile-fcntllock-perl \
libio-socket-ip-perl \
libio-socket-ssl-perl \
libjson-perl \
libjson-xs-perl \
libmail-sendmail-perl \
libsocket-perl \
libswitch-perl \
libsys-hostname-long-perl \
libterm-readkey-perl \
libterm-readline-perl-perl \
libwww-perl \
libdbd-sqlite3-perl \
libtext-diff-perl \
libxml-simple-perl \
libjson-perl \
libsoap-lite-perl \ 
libjson-xs-perl \
libsnmp-perl \
libnet-telnet-perl \
libmime-lite-perl \
libxml-simple-perl \
libdigest-crc-perl \
libcrypt-cbc-perl \
libio-socket-timeout-perl \
libmime-lite-perl \
libdevice-serialport-perl \
libdbd-pg-perl \
libdbd-mysql \
libdbd-mysql-perl \
libimage-librsvg-perl \
libav-tools \
&& apt-get clean

# whatsapp Python yowsup
RUN apt-get -y --force-yes install \
python-soappy \
python-dateutil \
python-pip \
python-dev \
build-essential \
libgmp10 \
&& apt-get clean

# whatsapp images
RUN apt-get -y --force-yes install \
libtiff5-dev \
libjpeg-dev \
zlib1g-dev \
libfreetype6-dev \
liblcms2-dev \
libwebp-dev \
tcl8.5-dev \
tk8.5-dev \
python-tk \
&& apt-get clean


# Pyhton stuff
RUN pip install --upgrade pip \
 && pip install python-axolotl --upgrade \
 && pip install pillow --upgrade

RUN pip install yowsup2 --upgrade


# install yowsup-client
WORKDIR /opt
RUN mkdir /opt/yowsup-config
RUN wget -N https://github.com/tgalal/yowsup/archive/master.zip
RUN unzip -o master.zip && rm master.zip

#mod # install fhem (debian paket)
WORKDIR /opt
RUN wget https://fhem.de/fhem-${FHEM_VERSION}.deb && dpkg -i fhem-${FHEM_VERSION}.deb
#RUN rm fhem-${FHEM_VERSION}.deb
RUN echo 'fhem    ALL = NOPASSWD:ALL' >>/etc/sudoers
RUN echo 'attr global pidfilename /var/run/fhem/fhem.pid' >> /opt/fhem/fhem.cfg

RUN apt-get -y --force-yes install supervisor 
RUN mkdir -p /var/log/supervisor


#mod # Do some stuff
RUN echo Europe/Berlin > /etc/timezone && dpkg-reconfigure tzdata  \
 && apt-get -y --force-yes install at cron && apt-get clean


# sshd on port 2222 and allow root login / password = Fhem!
RUN apt-get -y --force-yes install openssh-server && apt-get clean   \
 && sed -i 's/Port 22/Port 2222/g' /etc/ssh/sshd_config  \
 && sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config \
 && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config \
 && echo "root:fhem!" | chpasswd \
 && /bin/rm  /etc/ssh/ssh_host_*
# RUN dpkg-reconfigure openssh-server

# NFS client / autofs
RUN apt-get  -y --force-yes install nfs-common autofs && apt-get clean && apt-get autoremove
RUN echo "/net /etc/auto.net --timeout=60" >> /etc/auto.master

ENV RUNVAR fhem
WORKDIR /root

# SSH / Fhem ports 
EXPOSE 2222 7072 8083 8084 8085 9001

ADD run.sh /root/
ADD runfhem.sh /root/
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir /_cfg  
ADD volumedata2.sh /_cfg/
RUN chmod +x /root/run.sh && chmod +x /root/runfhem.sh && chmod +x /_cfg/*.sh && chmod +x /root/run.sh
RUN /_cfg/volumedata2.sh create /opt/fhem \
 && /_cfg/volumedata2.sh create /opt/yowsup-config \
 && touch /opt/yowsup-config/empty.txt

ENTRYPOINT ["./run.sh"]
#CMD ["arg1"]

# last add volumes
VOLUME /opt/fhem   /opt/yowsup-config

#TESTING
# RUN apt-get -y --force-yes install php5-cli php5-mysql && apt-get clean

# End Dockerfile
