FROM debian:jessie

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
RUN apt-get install -y dnsutils tar wget vim unzip curl procps

#
# Install Nginx
#
ENV NGINX_VERSION 1.9.12-1~jessie

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y \
						ca-certificates \
						nginx=${NGINX_VERSION} \
						nginx-module-xslt \
						nginx-module-geoip \
						nginx-module-image-filter \
						gettext-base \
	&& rm -rf /var/lib/apt/lists/*

#
# Clean up Nginx Default Files
#
RUN rm -rf /usr/share/nginx/www
RUN rm -rf /etc/nginx/sites-enabled

#
# Copy over default config
#
ADD nginx.conf /etc/nginx
ADD www /usr/share/nginx/www
ADD sites-enabled /etc/nginx/sites-enabled

#
# Expose the Ports
#
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]