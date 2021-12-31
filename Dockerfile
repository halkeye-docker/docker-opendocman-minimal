FROM php:7.4.27-apache

LABEL maintainer="Gavin Mogan <docker@gavinmogan.com>"

EXPOSE 80

VOLUME /var/www/odm_data/

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN docker-php-ext-install \
          pdo \
          pdo_mysql

RUN curl -qsL https://github.com/opendocman/opendocman/archive/refs/heads/master.tar.gz | tar xzf - --strip-components=1 -C /var/www/html && \
      chown -R www-data:www-data /var/www/html && \
      chmod 777 /var/www/html/templates_c

