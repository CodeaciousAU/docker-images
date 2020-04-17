ARG php_version=latest
FROM codeacious/common-php:$php_version
USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apache2 \
        libapache2-mod-auth-pubtkt \
        libapache2-mod-auth-openidc \
    && rm -rf /var/lib/apt/lists/*

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

COPY include /etc/apache2/include/
COPY conf/* /etc/apache2/conf-available/
COPY 000-default.conf /etc/apache2/sites-available/
COPY index.html /var/www
COPY php-fpm.conf /usr/local/etc/php-fpm.d/docker.conf

RUN a2enmod \
        expires \
        headers \
        proxy \
        proxy_http \
        proxy_fcgi \
        proxy_wstunnel \
        remoteip \
        rewrite \
        ssl \
        vhost_alias
RUN a2dismod status auth_pubtkt
RUN a2enconf logging security server-admin ssl-stapling
RUN a2disconf charset localized-error-pages other-vhosts-access-log serve-cgi-bin

RUN mkdir -p /srv/config/sites \
    && mkdir -p /srv/app/public
WORKDIR /srv/app
ADD app.conf /srv/config/sites/
RUN rm -Rf /var/www/html \
    && mkdir -p /var/lock/apache2 \
    && chown www-data:www-data /var/lock/apache2

# Install php-fpm metrics exporter
RUN curl -sL https://github.com/hipages/php-fpm_exporter/releases/download/v1.0.0/php-fpm_exporter_1.0.0_linux_amd64 \
  -o /usr/local/bin/php-fpm_exporter \
    && chmod +x /usr/local/bin/php-fpm_exporter

COPY httpd-foreground /usr/local/bin/
COPY docker-entrypoint.sh /

ENV PATH "$PATH:/srv/app:/srv/app/vendor/bin:/srv/app/node_modules/.bin"
EXPOSE 80
EXPOSE 443
EXPOSE 9253

STOPSIGNAL SIGTERM
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["httpd-foreground"]
