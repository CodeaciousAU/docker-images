FROM php:7.4-fpm-buster
SHELL ["/bin/bash", "-c"]

# Build (but don't enable) commonly used PHP modules
RUN apt-get update \
    && apt-get install -y \
        git \
        gnupg \
        libfreetype6 \
        libfreetype6-dev \
        libgmp10 \
        libgmp-dev \
        libicu63 \
        libicu-dev \
        libjpeg62-turbo \
        libjpeg62-turbo-dev \
        libldb1 \
        libldb-dev \
        libldap-2.4-2 \
        libldap2-dev \
        libmagickcore-6.q16-6 \
        libmagickcore-dev \
        libmagickwand-6.q16-6 \
        libmagickwand-dev \
        libmemcached11 \
        libmemcachedutil2 \
        libmemcached-dev \
        libpng16-16 \
        libpng-dev \
        libsasl2-2 \
        libsasl2-dev \
        libssl-dev \
        libzip4 \
        libzip-dev \
        zip \
    && docker-php-ext-enable opcache \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap --with-ldap-sasl \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        bz2 \
        gd \
        gmp \
        intl \
        ldap \
        mysqli \
        pcntl \
        pdo_mysql \
        zip \
    && rm /usr/local/etc/php/conf.d/docker-php-ext-{bcmath,bz2,gd,gmp,intl,ldap,mysqli,pcntl,pdo_mysql,zip}.ini \
    && pecl install \
        imagick \
        memcached \
        mongodb \
        xdebug \
    && rm -Rf /tmp/pear \
    && apt-get remove -y --purge \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libldb-dev \
        libldap2-dev \
        libmagickcore-dev \
        libmagickwand-dev \
        libmemcached-dev \
        libpng-dev \
        libsasl2-dev \
        libssl-dev \
        libzip-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install xhprof extension
RUN cd /tmp \
    && curl -L -o xhprof.deb https://github.com/tideways/php-xhprof-extension/releases/download/v5.0.2/tideways-xhprof_5.0.2_amd64.deb \
    && dpkg -i xhprof.deb \
    && rm xhprof.deb \
    && ln -s /usr/lib/tideways_xhprof/tideways_xhprof-7.4.so "$(php -d 'display_errors=stderr' -r 'echo ini_get("extension_dir");')/tideways_xhprof.so"

# Install Node and NPM
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y \
        nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install composer
RUN php -r "copy('https://getcomposer.org/composer.phar', '/usr/local/bin/composer');" \
    && chmod +x /usr/local/bin/composer \
    && mkdir -p /var/lib/composer \
    && chmod 777 /var/lib/composer
ENV COMPOSER_HOME=/var/lib/composer
ADD config.json /var/lib/composer/

RUN chown -R www-data:www-data /var/www

ADD php.ini /usr/local/etc/php/
ADD xdebug.ini /usr/local/etc/php/conf.d/

USER www-data
CMD ["php"]
