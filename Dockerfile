FROM --platform=$TARGETPLATFORM dunglas/frankenphp@sha256:fe24f036eb12f799c4f782224d05483f843b1af75a37b18f956e0adbef463ead AS base
USER root
RUN install-php-extensions \
      exif \
      gd \
      mysqli \
      opcache
RUN pecl install redis \
  && docker-php-ext-enable redis
# disable https in Caddy
RUN sed -i \
      -e "s#{\$SERVER_NAME:localhost}#:80#" \
      -e "s#public#/var/www/html#" \
      /etc/caddy/Caddyfile
WORKDIR /var/www
RUN chown -R www-data: .
USER www-data

FROM --platform=$TARGETPLATFORM base AS build
USER root
RUN apt-get update && apt-get install -y zip git
COPY --from=composer/composer:2-bin@sha256:989ad47cea06cb9365afda43d7431a238c6abf913d631b9cf043eb0d43f783ae /composer /usr/bin/composer
USER www-data
WORKDIR /var/www/html
ADD --chown=www-data:www-data composer.json .
RUN composer install \
 && composer run-script post-install-cmd

FROM --platform=$TARGETPLATFORM base as prod
COPY --from=build /var/www/html /var/www/html
USER root
RUN ln -s $(pwd)/html/wp-content/vendor/wp-cli/wp-cli/bin/wp /usr/bin/wp
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
USER www-data
WORKDIR /var/www/
ADD --chown=www-data:www-data wp-config.php html/
ADD --chown=www-data:www-data s3-endpoint.php html/wp-content/mu-plugins/
