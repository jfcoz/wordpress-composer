FROM --platform=$TARGETPLATFORM dunglas/frankenphp@sha256:84c057ddd9c74808f49e08c20d6aa945e967b00b2de058d9508a4257ef0764b3 AS base
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
COPY --from=composer/composer:2-bin@sha256:e815f9ba494ba25344c55bfaaafdcc309145a6da09c96dfde9c68e7514412728 /composer /usr/bin/composer
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
