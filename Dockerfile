FROM --platform=$TARGETPLATFORM dunglas/frankenphp@sha256:661bbd11ce8b9bbf51ba6e13d1cb7ea533466984142d936411df325922c4cdb1 AS base
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
COPY --from=composer/composer:2-bin@sha256:a80b4fafbb5427e57f40a4f845415185bdc0461e280066d27baefaf3734e7a9b /composer /usr/bin/composer
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
