# Copyright (c) 2018 Joscha Middendorf

FROM debian:stretch

MAINTAINER Joscha Middendorf <joscha.middendorf@me.com>

ENV FHEM_VERSION 5.8
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
ENV TZ Europe/Berlin

# Install dependencies
RUN apt-get update && apt-get upgrade -y --force-yes && apt-get install -y --force-yes --no-install-recommends apt-utils











CMD /bin/bash

# End Dockerfile
