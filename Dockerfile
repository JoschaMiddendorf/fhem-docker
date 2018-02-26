# Copyright (c) 2018 Joscha Middendorf

FROM debian:jessie

MAINTAINER Joscha Middendorf <joscha.middendorf@me.com>

ENV FHEM_VERSION 5.8
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# Install dependencies
RUN apt-get update && apt-get upgrade -y --force-yes && apt-get install -y --force-yes --no-install-recommends apt-utils
RUN apt-get -y --force-yes install \
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
  snmpd \
  sqlite3 \
  sudo \
  telnet-ssl \
  usbutils \
  usbutils \
  vim \
  wget

  #&& apt-get install -y --force-yes --no-install-recommends apt-utils \
  #bluetooth \
  #bluez-hcidump \
  #bluez \
  #blueman 

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
  libxml-simple-perl

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure Timezone
RUN echo Europe/Berlin > /etc/timezone && dpkg-reconfigure tzdata

# Install Speedtest-CLI 
RUN cd /usr/local/bin \
  && wget -O speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py \
  && chmod +x speedtest-cli

# Install FHEM (FHEM_VERSION)
RUN wget https://fhem.de/fhem-${FHEM_VERSION}.deb && dpkg -i fhem-${FHEM_VERSION}.deb
RUN rm fhem-${FHEM_VERSION}.deb
RUN userdel fhem


# add basic configation and StartAndInitialisation script
ADD fhem.cfg /opt/fhem/
ADD controls.txt /opt/fhem/FHEM/
ADD StartAndInitialize.sh /root/
RUN chmod +x /root/StartAndInitialize.sh

# compress FHEM base data from /opt/fhem/ for initialisation of volumes
RUN /root/StartAndInitialize.sh initialize /opt/fhem

# open ports 
EXPOSE 7072 8083 8084 8085 8086 8087 8088 8089

# add volumes
VOLUME /opt/fhem

# Default arguments to execute the entrypoint
ENTRYPOINT ["/root/StartAndInitialize.sh"]
CMD ["extract", "/opt/fhem"]

# End Dockerfile
