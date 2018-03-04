## Copyright (c) 2018 Joscha Middendorf

FROM debian:stretch

MAINTAINER Joscha Middendorf <joscha.middendorf@me.com>

ENV FHEM_VERSION 5.8
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
ENV TZ Europe/Berlin

## Install dependencies
RUN apt-get update
RUN apt-get upgrade -y
#RUN apt-get install -y --force-yes --no-install-recommends apt-utils
RUN apt-get install -y --force-yes \
  apt-transport-https \
  build-essential \
  curl \
  dfu-programmer \
  etherwake \
  git \
  nano \
  perl \
  screenfetch \
  snmp \
  snmpd \
  sqlite3 \
  sudo \
  telnet-ssl \
  usbutils \
  wget

## Install perl packages
RUN apt-get install -y --force-yes \
  libalgorithm-merge-perl \
  libauthen-oath-perl \
  libavahi-compat-libdnssd-dev \
  libcgi-pm-perl \
  libclass-dbi-mysql-perl \
  libclass-isa-perl \
  libcommon-sense-perl \
  libconvert-base32-perl \
  libcrypt-urandom-perl \
  libdata-dump-perl \
  libdatetime-format-strptime-perl \
  libdbd-sqlite3-perl \
  libdbi-perl \
  libdevice-serialport-perl \
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
  libjson-perl \
  libjson-xs-perl \
  liblist-moreutils-perl \
  libmail-imapclient-perl \
  libmail-sendmail-perl \
  libmime-base64-perl \
  libnet-telnet-perl \
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
  libxml-simple-perl
  
## Install more dependencies
#RUN apt-get install -y --force-yes \
  #at \
  #cron \
  #bluetooth \
  #bluez-hcidump \
  #bluez \
  #blueman 
  #dialog \
  #g++ \
  #gcc \
  #htop \
  #imagemagick \
  #libavahi-compat-libdnssd-dev \
  #libssl-dev \
  #lsof \
  #make \
  #mc \
  #mysql-client \
  #vim \
  #nodejs

## Install more perl packages
#RUN apt-get install -y --force-yes \
  #libav-tools \
  #libcrypt-cbc-perl \
  #libdbd-mysql \
  #libdbd-mysql-perl \
  #libdbd-pg-perl \
  #libdigest-crc-perl \
  #libio-socket-timeout-perl \
  #libmime-lite-perl \
  #libsnmp-perl

## Clean up APT when done.                ###################################
RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Configure Timezone
RUN echo ${TZ} > /etc/timezone && dpkg-reconfigure tzdata

## Customize console
RUN echo "alias ll='ls -lah --color=auto'" >> /root/.bashrc \
  && echo "screenfetch" >> /root/.bashrc

## Install Speedtest-CLI 
RUN cd /usr/local/bin \
  && wget -O speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py \
  && chmod +x speedtest-cli

## Install FHEM (FHEM_VERSION)
RUN wget https://fhem.de/fhem-${FHEM_VERSION}.deb && dpkg -i fhem-${FHEM_VERSION}.deb \
  && rm fhem-${FHEM_VERSION}.deb \
  && userdel fhem

## add basic configation and scripts
ADD fhem.cfg /opt/fhem/
ADD controls.txt /opt/fhem/FHEM/
ADD StartAndInitialize.sh /root/
ADD healthcheck.sh /root/
RUN chmod +x /root/*.sh

## compress FHEM base data from /opt/fhem/ for initialisation of volumes
RUN /root/StartAndInitialize.sh initialize /opt/fhem

## open ports 
EXPOSE 7072 8083 8084 8085 8086 8087 8088 8089

## add volumes
VOLUME /opt/fhem

## Healthcheck
HEALTHCHECK --interval=20s --timeout=10s --start-period=60s --retries=5 CMD /root/healthcheck.sh

## Entrypoint
ENTRYPOINT ["/root/StartAndInitialize.sh"]
CMD ["extract", "/opt/fhem"]

## End Dockerfile
