FROM php:7.1.9-fpm

MAINTAINER Lasarevs

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        libmemcached-dev \
        libz-dev \
        libjpeg-dev \
        libpng12-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        libpq-dev \
        libjpeg62-turbo-dev \
        git \
        mysql-client

RUN apt-get purge --auto-remove -y zlib1g-dev \
        && apt-get -y install \
            libssl-dev \
            libc-client2007e-dev \
            libkrb5-dev \
            libfreetype6-dev \
            libjpeg62-turbo-dev \
            libmcrypt-dev \
            libpng12-dev \
        && docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
        && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
        && docker-php-ext-install imap \
        && docker-php-ext-install -j$(nproc) gd \
        && docker-php-ext-install opcache \
        && docker-php-ext-install pdo_mysql \
        && docker-php-ext-install mcrypt

#####################################
# OpCahce
#####################################
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

#####################################
# ZipArchive:
#####################################

RUN docker-php-ext-install zip && \
    docker-php-ext-enable zip

#####################################
# Composer:
#####################################

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#####################################
# Set Timezone
#####################################

ARG TZ=UTC
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN composer global require "hirak/prestissimo:^0.3"
