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
  default-mysql-client \
  git \
  curl \
  libonig-dev \
  libzip-dev \
  cron \
  wget \
  wkhtmltopdf \
  --no-install-recommends \
  && rm -r /var/lib/apt/lists/* \
  && echo "daemon off;" >> /etc/nginx/nginx.conf

#update wkhtmltopdf to qt patch
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar xvf wkhtmltox*.tar.xz
RUN mv wkhtmltox/bin/wkhtmlto* /usr/bin

# Install supervisord
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord

RUN pecl install -o -f redis \
  &&  rm -rf /tmp/pear \
  &&  docker-php-ext-enable redis


ENV PHP_OPCACHE_ENABLE="1" \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
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

COPY ./docker/php/local.ini /usr/local/etc/php/conf.d/local.ini   
COPY ./docker/php/fpm.ini /usr/local/etc/php-fpm.d/www.conf.default

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'c31c1e292ad7be5f49291169c0ac8f683499edddcfd4e42232982d0fd193004208a58ff6f353fde0012d35fdd72bc394') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer


COPY ./composer.json /var/www/composer.json

#Install Dependencies 
RUN composer install --prefer-dist --no-scripts --no-dev --no-autoloader && rm -rf /root/.composer

# Copy existing application directory contents
COPY ./ /var/www

RUN composer dump-autoload --no-scripts --no-dev --optimize

RUN touch /var/www/storage/logs/horizon.log
RUN touch /var/www/storage/logs/redis-sub.log


RUN mkdir -p /var/log/php-fpm

RUN chown -R www-data:www-data /var/www
RUN chmod -R 755 /var/www/storage



# Expose port 9000 and start php-fpm server
EXPOSE 80
CMD ["supervisord","-c","/var/www/docker/supervisord.conf"]


