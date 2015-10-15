# Author: Tran Huu Cuong
# Date: 2015-10-06
#
# Source: https://github.com/docker-library/drupal/
#

# from https://www.drupal.org/requirements/php#drupalversions
FROM php:5.6-apache
MAINTAINER Tran Huu Cuong "tranhuucuong91@gmail.com"

# using apt-cacher-ng proxy for caching deb package
RUN echo 'Acquire::http::Proxy "http://172.17.42.1:3142/";' > /etc/apt/apt.conf.d/01proxy

ENV BUILD_DATE 2015-10-15
RUN apt-get update -qq

RUN a2enmod rewrite

# install the PHP extensions we need
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libpng12-dev libjpeg-dev libpq-dev \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y drush mysql-client postgresql-client

WORKDIR /var/www/html

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 7.39
ENV DRUPAL_MD5 6f42a7e9c7a1c2c4c9c2f20c81b8e79a

#RUN curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
RUN curl -fSL "http://172.17.42.1/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
    && echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
    && tar -xz --strip-components=1 -f drupal.tar.gz \
    && rm drupal.tar.gz \
    && chown -R www-data:www-data sites

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# Expose port apache2
EXPOSE 80

# Start service
CMD ["apache2-foreground"]

