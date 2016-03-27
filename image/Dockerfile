FROM debian:7

MAINTAINER Henry Seurer "henryse@gmail.com"

#
# Set correct environment variables.
#
ENV	HOME /root
ARG PROJECT_VERSION=latest
ARG PROJECT_NAME=not_defined

#
# Setting the timezone to PST
#
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#
# Install base requirements and handy utilities, these are NOT required for
# Nginx but they are very handy when debugging stuff.
#
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install -y libreadline-dev libncurses5-dev libpcre3-dev \
    libssl-dev uuid-dev perl make build-essential dnsutils \
    tar wget vim unzip curl git procps ca-certificates \
    gcc python mysql-client

#
# Install Nginx
#
RUN apt-get install -y nginx

#
# Expose the Ports
#
EXPOSE 80
EXPOSE 443