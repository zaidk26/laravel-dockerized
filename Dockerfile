FROM php:7.4-fpm as PHP

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
  nginx \
  build-essential \
  libpng-dev \
  libjpeg62-turbo-dev \
  libfreetype6-dev \
  locales \
  zip \
  jpegoptim optipng pngquant gifsicle \
  vim \
  unzip \
  git \
  curl \
  libonig-dev \
  libzip-dev \
  cron \
  --no-install-recommends \
  && rm -r /var/lib/apt/lists/* \
  && echo "daemon off;" >> /etc/nginx/nginx.conf

# Install supervisord
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord

RUN pecl install -o -f redis \
  &&  rm -rf /tmp/pear \
  &&  docker-php-ext-enable redis


ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

RUN docker-php-ext-install opcache
COPY ./docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

COPY ./docker/nginx/conf.d/app.conf /etc/nginx/sites-available/default

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/
RUN docker-php-ext-install gd


# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer



# Add user for laravel application
# RUN groupadd -g 1000 www
# RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY ./ /var/www

COPY ./docker/php/local.ini /usr/local/etc/php/conf.d/local.ini   
COPY ./docker/php/fpm.ini /usr/local/etc/php-fpm.d/www.conf.default

RUN touch /var/www/storage/logs/horizon.log
RUN touch /var/www/storage/logs/redis-sub.log


RUN mkdir -p /var/log/php-fpm


# Copy existing application directory permissions
# RUN chown -R www:www /var/www
# RUN chown -R www:www /var/log/php-fpm

RUN chown -R www-data:www-data /var/www
RUN chmod -R 755 /var/www/storage

# Setup cron job
#RUN (crontab -l ; echo "* * * * * /usr/local/bin/php /srv/app/artisan schedule:run >> /dev/null 2>&1") | crontab

# Install caddy
#COPY --from=caddy:2.0.0 /usr/bin/caddy /usr/local/bin/caddy



#Install Dependencies and Run Migrations
RUN composer install --no-dev --no-interaction --optimize-autoloader


# Expose port 9000 and start php-fpm server
EXPOSE 80
CMD ["supervisord","-c","/var/www/docker/supervisord.conf"]
