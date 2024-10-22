# Use the official PHP image with Apache
FROM php:8.1-apache

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \ 
    libzip-dev \ 
    zip \
    unzip \
    curl \
    vim \
    git \
    default-mysql-client

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo_mysql mbstring zip exif pcntl gd mysqli

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy composer for Laravel
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Ensure that the public directory is present
RUN mkdir -p /var/www/html/public

# Add a simple index file to the app
RUN echo "<?php echo 'Welcome to Laravel!'; ?>" > /var/www/html/public/index.php

# Copy the application files to the container
COPY . .

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Create the storage and cache directories if they don't exist
RUN mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public


# Set proper permissions for Laravel storage and bootstrap/cache directories
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Copy Apache configuration for Laravel
COPY .docker/apache/laravel.conf /etc/apache2/sites-available/000-default.conf

# Enable the new Apache configuration
RUN a2ensite 000-default.conf

# Update Apache configuration to use /var/www/html/public
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Copy the updated Apache configuration file to use port 8000
RUN sed -i 's/Listen 80/Listen 8000/' /etc/apache2/ports.conf

# Expose port 8000 for HTTP
EXPOSE 8000

# Start Apache service
CMD ["apache2-foreground"]
