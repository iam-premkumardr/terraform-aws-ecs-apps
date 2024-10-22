# Use an official PHP runtime as a parent image
FROM php:7.4-apache

RUN apt-get update && apt-get install -y curl

# Set the working directory in the container
WORKDIR /var/www/html

# Copy the current directory contents into the container
COPY . /var/www/html

# Install any required PHP extensions (if necessary)
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Start the PHP built-in web server
CMD ["php", "-S", "0.0.0.0:9000", "-t", "/var/www/html"]
