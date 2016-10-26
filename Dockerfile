FROM ubuntu:16.04

MAINTAINER Gerhard Richard Edens <richard.edens@annalect.com>

# ---------------------------------------------------------------------------------------
 #  Environment
 # ---------------------------------------------------------------------------------------  
ENV TERM xterm
RUN LC_ALL=C.UTF-8

# ---------------------------------------------------------------------------------------
 #  Install PHP
 # ---------------------------------------------------------------------------------------  
RUN apt-get update \
 && apt-get install -y tidy \
 net-tools \
 traceroute \
 iputils-ping \
 wget \
 unzip \
 zip \
 nano \
 git \
 php \
 php-xsl \
 php-common \
 php-json \
 php-curl \
 php-dom \
 php-intl \
 php-json \
 php-ldap \
 php-mbstring \
 php-mcrypt \
 php-mysql \
 php-zip \
 php-imap \
 php-tidy \
 php-gd \
 php-bz2 \
 php-mysql \
 nginx-full \
 curl \
 build-essential \
 nodejs \
 npm \
 && apt-get remove --purge -y $BUILD_PACKAGES \
 && rm -rf /var/lib/apt/lists/* \
 && echo "cgi.fix_pathinfo=0" >> /etc/php/7.0/fpm/php.ini \
 && echo "access.log = /proc/self/fd/2" > /etc/php/7.0/fpm/php-fpm.log \
 && echo "error_log = /proc/self/fd/2" >> /etc/php/7.0/fpm/php-fpm.log

# ---------------------------------------------------------------------------------------
 #  Install MySQL package
 # ---------------------------------------------------------------------------------------  
RUN npm install -g bower

# ---------------------------------------------------------------------------------------
 #  Install MySQL package
 # ---------------------------------------------------------------------------------------  
RUN echo "mysql-server mysql-server/root_password password devpass" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password devpass" | debconf-set-selections
RUN apt-get update && apt-get install -y mysql-server mysql-client
RUN usermod -d /var/lib/mysql/ mysql
RUN update-rc.d mysql defaults

 # ---------------------------------------------------------------------------------------
 #  Install Composer
 # ---------------------------------------------------------------------------------------  
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod a+x /usr/local/bin/composer

# ---------------------------------------------------------------------------------------
 #  Create default website
 # ---------------------------------------------------------------------------------------  
COPY conf/site.conf /etc/nginx/sites-available/default
COPY Procfile /

# ---------------------------------------------------------------------------------------
 #  Forego
 # ---------------------------------------------------------------------------------------  
RUN curl -O https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-amd64.tgz \
 && tar -xzf forego-stable-linux-amd64.tgz -C /usr/bin \
 && rm forego-stable-linux-amd64.tgz \
 && mkdir -p /run/php

# ---------------------------------------------------------------------------------------
 #  Add files
 # ---------------------------------------------------------------------------------------  
RUN mkdir /var/www/html/public
ADD src/ /var/www/html/public/
ADD errors/ /var/www/errors

# ---------------------------------------------------------------------------------------
 #  Create volume
 # ---------------------------------------------------------------------------------------  
VOLUME /var/www/html

# ---------------------------------------------------------------------------------------
 #  Expose ports
 # ---------------------------------------------------------------------------------------  
EXPOSE 443 80

# ---------------------------------------------------------------------------------------
 #  Make a new entrypoint
 # ---------------------------------------------------------------------------------------  
ENTRYPOINT forego start
