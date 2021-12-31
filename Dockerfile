FROM php:7.4.27-apache

LABEL maintainer=""

EXPOSE 80

VOLUME /var/www/odm_data/

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN docker-php-ext-install \
          pdo \
          pdo_mysql \
          opcache

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
ENV MAX_EXECUTION_TIME 600
ENV MEMORY_LIMIT 512M
ENV UPLOAD_LIMIT 2048K
RUN set -ex; \
    \
    { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
    } > $PHP_INI_DIR/conf.d/opcache-recommended.ini; \
    \
    { \
        echo 'session.cookie_httponly=1'; \
        echo 'session.use_strict_mode=1'; \
    } > $PHP_INI_DIR/conf.d/session-strict.ini; \
    \
    { \
        echo 'allow_url_fopen=Off'; \
        echo 'max_execution_time=${MAX_EXECUTION_TIME}'; \
        echo 'max_input_vars=10000'; \
        echo 'memory_limit=${MEMORY_LIMIT}'; \
        echo 'post_max_size=${UPLOAD_LIMIT}'; \
        echo 'upload_max_filesize=${UPLOAD_LIMIT}'; \
    } > $PHP_INI_DIR/conf.d/phpmyadmin-misc.ini


ENV VERSION 1.4.4
LABEL org.opencontainers.image.title="Open Doc Manager Docker Image" \
    org.opencontainers.image.description="Run opendockman" \
    org.opencontainers.image.authors="Gavin Mogan <docker@gavinmogan.com>" \
    org.opencontainers.image.vendor="halkeye/docker" \
    org.opencontainers.image.documentation="https://github.com/halkeye-docker/docker-opendocman-minimal#readme" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.url="https://github.com/halkeye-docker/docker-opendocman-minimal#readme" \
    org.opencontainers.image.source="https://github.com/halkeye-docker/docker-opendocman-minimal.git"


RUN curl -qsL https://github.com/opendocman/opendocman/archive/refs/tags/${VERSION}-release.tar.gz | tar xzf - --strip-components=1 -C /var/www/html && \
      chown -R www-data:www-data /var/www/html && \
      cp /var/www/html/config-sample.php /var/www/html/config.php && \
      mkdir -p /var/www/odm_data && \
      chmod 777 /var/www/odm_data && \
      chmod 777 /var/www/html/templates_c
COPY files/config.php /var/www/html/config.php
