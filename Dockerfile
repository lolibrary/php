FROM composer:latest as composer
FROM alpine:3.7

LABEL maintainer="amelia@lolibrary.org"

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_NO_INTERACTION 1
ENV COMPOSER_HOME /usr/lib/composer
ENV COMPOSER_CACHE_DIR /var/cache/composer

# key from https://php.codecasts.rocks/php-alpine.rsa.pub on 2018-03-30T09:14:00+01:00
COPY codecasts.pub /etc/apk/keys/php-alpine.rsa.pub

# add the www-data user
RUN set -x \
    && apk --update add ca-certificates \
    && update-ca-certificates \
    && echo "@php https://php.codecasts.rocks/v3.7/php-7.2" >> /etc/apk/repositories \
    && apk --update add \
        php7@php \
        php7-fpm@php \
        php7-ctype@php \
        php7-curl@php \
        php7-dom@php \
        php7-gd@php \
        php7-iconv@php \
        php7-intl@php \
        php7-json@php \
        php7-mbstring@php \
        php7-opcache@php \
        php7-openssl@php \
        php7-pcntl@php \
        php7-phar@php \
        php7-posix@php \
        php7-session@php \
        php7-xml@php \
        php7-zip@php \
        php7-zlib@php \
        php7-pdo_pgsql@php \
    && ln -s /usr/bin/php7 /usr/bin/php \
    && rm -rf /var/cache/apk/* \
    && rm /etc/init.d/php-fpm7 \
    && mkdir -p /srv/code

# copy over composer
COPY --from=composer /usr/bin/composer /usr/bin

# add fpm files
COPY ["php-fpm.conf", "php.ini", "/etc/php7/"]

RUN composer global require hirak/prestissimo \
    && rm -rf /var/cache/composer/* \
    && php-fpm7 -t

WORKDIR /srv/code

EXPOSE 9000

CMD ["PHP_INI_SCAN_DIR=/etc/php7/conf.d", "/usr/sbin/php-fpm7", "-c", "/etc/php7/php.ini", "--nodaemonize"]
