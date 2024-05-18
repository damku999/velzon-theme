FROM php:8.2.12-cli

# RUN apt-get update -y && apt-get install -y libonig-dev unzip
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    libzip-dev \
    zlib1g-dev \
    unzip \
    libicu-dev

    # Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*


RUN sed -i 's/post_max_size = 8M/post_max_size = 1024M/g' /usr/local/etc/php/php.ini-development && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1024M/g' /usr/local/etc/php/php.ini-development && \
    sed -i 's/max_execution_time = 30/max_execution_time = 1000/g' /usr/local/etc/php/php.ini-development && \
    sed -i 's/memory_limit = 128M/memory_limit = 2048M/g' /usr/local/etc/php/php.ini-development && \
    sed -i 's/max_input_time = 60/max_input_time = 600/g' /usr/local/etc/php/php.ini-development

RUN sed -i 's/post_max_size = 8M/post_max_size = 1024M/g' /usr/local/etc/php/php.ini-production && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1024M/g' /usr/local/etc/php/php.ini-production && \
    sed -i 's/max_execution_time = 30/max_execution_time = 1000/g' /usr/local/etc/php/php.ini-production && \
    sed -i 's/memory_limit = 128M/memory_limit = 2048M/g' /usr/local/etc/php/php.ini-production && \
    sed -i 's/max_input_time = 60/max_input_time = 600/g' /usr/local/etc/php/php.ini-production

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 1024M/g' /usr/local/etc/php/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1024M/g' /usr/local/etc/php/php.ini && \
    sed -i 's/max_execution_time = 30/max_execution_time = 1000/g' /usr/local/etc/php/php.ini && \
    sed -i 's/memory_limit = 128M/memory_limit = 2048M/g' /usr/local/etc/php/php.ini && \
    sed -i 's/max_input_time = 60/max_input_time = 600/g' /usr/local/etc/php/php.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl xml bcmath gd zip intl

RUN docker-php-ext-enable zip intl

WORKDIR /app
COPY . /app
# COPY .env.example /app/.env
RUN unzip ./public/build.zip -d ./app/public


RUN composer install --optimize-autoloader --no-dev
RUN php -m
RUN php artisan log-viewer:publish
EXPOSE 8000
CMD php artisan serve --host=0.0.0.0 --port=8000
