# Copyright (c) 2018 Joscha Middendorf

FROM debian:jessie

MAINTAINER Joscha Middendorf <joscha.middendorf@me.com>

ENV FHEM_VERSION 5.8
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm


# Install dependencies
RUN apt-get -y --force-yes install apt-utils \
&& apt-get update \
&& apt-get upgrade -y --force-yes \
&& apt-get -y --force-yes install \
apt-transport-https \
at \
build-essential \
cron \
curl \
dfu-programmer \
dialog \
etherwake \
g++ \
gcc \
git \
htop \
imagemagick \
libavahi-compat-libdnssd-dev \
libssl-dev \
lsof \
make \
mc \
mysql-client \
nano \
nodejs \
perl \
snmp \
snmp \
snmpd \
sqlite3 \
sudo \
telnet-ssl \
usbutils \
usbutils \
vim \
vim \
wget \
&& apt-get clean

#&& apt-get install -y --force-yes --no-install-recommends apt-utils \
#bluetooth \
#bluez-hcidump \
#bluez \
#blueman \


# Install perl packages
RUN apt-get -y --force-yes install \
libalgorithm-merge-perl \
libauthen-oath-perl \
libavahi-compat-libdnssd-dev \
libav-tools \
libcgi-pm-perl \
libclass-dbi-mysql-perl \
libclass-isa-perl \
libcommon-sense-perl \
libconvert-base32-perl \
libcrypt-cbc-perl \
libcrypt-urandom-perl \
libdata-dump-perl \
libdatetime-format-strptime-perl \
libdbd-mysql \
libdbd-mysql-perl \
libdbd-pg-perl \
libdbd-sqlite3-perl \
libdbi-perl \
libdevice-serialport-perl \
libdigest-crc-perl \
libdpkg-perl \
liberror-perl \
libfile-copy-recursive-perl \
libfile-fcntllock-perl \
libgd-graph-perl \
libgd-text-perl \
libimage-info-perl \
libimage-librsvg-perl \
libio-socket-inet6-perl \
libio-socket-ip-perl \
libio-socket-multicast-perl \
libio-socket-ssl-perl \
libio-socket-timeout-perl \
libjson-perl \
libjson-xs-perl \
liblist-moreutils-perl \
libmail-imapclient-perl \
libmail-sendmail-perl \
libmime-base64-perl \
libmime-lite-perl \
libnet-telnet-perl \
libsnmp-perl \
libsoap-lite-perl \
libsocket-perl \
libsocket6-perl \
libswitch-perl \
libsys-hostname-long-perl \
libterm-readkey-perl \
libterm-readline-perl-perl \
libtext-csv-perl \
libtext-diff-perl \
libtimedate-perl \
libwww-perl \
libxml-simple-perl \
&& apt-get clean


# Configure Timezone
RUN echo Europe/Berlin > /etc/timezone && dpkg-reconfigure tzdata

# Install Speedtest-CLI 
RUN cd /usr/local/bin \
 && wget -O speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py \
 && chmod +x speedtest-cli

# Install FHEM (FHEM_VERSION)
#WORKDIR /opt
RUN wget https://fhem.de/fhem-${FHEM_VERSION}.deb && dpkg -i fhem-${FHEM_VERSION}.deb
RUN rm fhem-${FHEM_VERSION}.deb
RUN userdel fhem
#RUN echo 'fhem    ALL = NOPASSWD:ALL' >>/etc/sudoers




# define directory
# WORKDIR "/opt/fhem"

# add Configuration and start scripts
ADD start.sh /root/
ADD volumedata2.sh /root/
#RUN chmod +x /root/run.sh && chmod +x /root/runfhem.sh && chmod +x /_cfg/*.sh && chmod +x /root/run.sh

# open ports 
EXPOSE 8083 8089 7072

# add volumes
VOLUME /opt/fhem

# if empty, extract FHEM data to /opt/fhem
RUN /root/volumedata2.sh create /opt/fhem

# Start FHEM
CMD bash /opt/fhem/start.sh

# End Dockerfile




#ADD run.sh /root/
#ADD runfhem.sh /root/
#ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf


#RUN chmod +x /root/run.sh && chmod +x /root/runfhem.sh && chmod +x /_cfg/*.sh && chmod +x /root/run.sh
#RUN /_cfg/volumedata2.sh create /opt/fhem \
# && /_cfg/volumedata2.sh create /opt/yowsup-config \
# && touch /opt/yowsup-config/empty.txt

#ENTRYPOINT ["./run.sh"]
#CMD ["arg1"]
