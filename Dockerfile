## *** try again during pacjage installation if failed *** repository server may not available that time but few minutes later it wiill work
FROM ubuntu:22.04

MAINTAINER ISAHAK ALI isahak05ice@gmail.com

RUN apt-get update
RUN apt-get -y upgrade
RUN apt install software-properties-common -y

RUN add-apt-repository ppa:ondrej/php
RUN  apt-get update -y
RUN  apt-get install  php5.6-fpm php5.6-cli php5.6-xml php5.6-mysql unzip -y

RUN apt-get install php5.6-gd php5.6-mysql php5.6-imap php5.6-curl php5.6-intl  -y

RUN apt-get install php5.6-curl  php5.6-mysql  php5.6-ldap  php5.6-zip php5.6-fileinfo -y
RUN apt-get install php5.6-mcrypt  php5.6-gd  -y

RUN apt-get install  libaio1 -y

RUN apt-get install build-essential -y
RUN apt-get install php5.6-gd  php5.6-opcache php5.6-soap -y

##
RUN apt-get install  php5.6-dev -y
RUN  apt-get install php-pear -y

RUN apt-get install  php5.6-bcmath php5.6-dom  php5.6-ctype  -y
RUN apt-get install php5.6-iconv php5.6-intl php5.6-json  -y
RUN apt-get install php5.6-mcrypt     php5.6-phar php5.6-pdo   -y


## oracle client

RUN apt-get install wget  systemtap-sdt-dev -y


ADD index.php /usr/share/nginx/html/


ADD instantclient-basic-linux.x64-21.9.0.0.0dbru.zip /tmp/
ADD instantclient-sdk-linux.x64-21.9.0.0.0dbru.zip /tmp/

WORKDIR /tmp
RUN mkdir /opt/oracle
RUN unzip instantclient-basic-linux.x64-21.9.0.0.0dbru.zip -d /opt/oracle
RUN unzip instantclient-sdk-linux.x64-21.9.0.0.0dbru.zip   -d /opt/oracle

RUN rm /tmp/*


RUN apt-get install libaio1 -y

RUN echo /opt/oracle/instantclient_21_9/  > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig

RUN pecl channel-update pecl.php.net
RUN export PHP_DTRACE=yes


#############################################################################################
RUN  export LD_LIBRARY_PATH=/opt/oracle/instantclient_21_9:$LD_LIBRARY_PATH
RUN  export PATH=/opt/oracle/instantclient_21_9/bin:$PATH
#RUN  source /root/.profile

RUN echo 'instantclient,/opt/oracle/instantclient_21_9/' | pecl install -f oci8-2.0.12

RUN   echo "extension=oci8.so" >> /etc/php/5.6/cli/php.ini
RUN   echo "extension=oci8.so" >> /etc/php/5.6/fpm/php.ini


RUN apt-get install wget -y
RUN wget https://nginx.org/packages/ubuntu/pool/nginx/n/nginx/nginx_1.22.1-1~jammy_amd64.deb
RUN  dpkg -i nginx_1.22.1-1~jammy_amd64.deb

# Start both PHP-FPM and Nginx services
#CMD service php5.6-fpm start
#CMD ["nginx", "-g", "daemon off;"]

ADD default.conf  /etc/nginx/conf.d/default.conf
ADD www.conf     /etc/php/5.6/fpm/pool.d/www.conf


RUN mkdir /run/php
RUN chown -R www-data:www-data /run/php && \
    chmod -R 777 /run/php

# Expose the HTTP and HTTPS ports
EXPOSE 80
EXPOSE 443

# Start both services
CMD service php5.6-fpm start && nginx -g 'daemon off;'
