FROM php:7.4-fpm-alpine

# Install system packages needed for PHP extensions and Nginx
RUN apk add --no-cache nginx curl \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    libzip-dev openldap-dev net-snmp-dev oniguruma-dev

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo_mysql gd bcmath zip opcache sockets

# Install optional extensions that are not compiled by default
RUN docker-php-ext-install ldap

RUN apk add --no-cache mariadb-client

# Download and extract RackTables
#RUN curl -sSL https://github.com/RackTables/racktables/archive/RackTables-0.22.0.tar.gz -o /tmp/racktables.tar.gz && \
#    tar -xzf /tmp/racktables.tar.gz -C /tmp && \
#    mv /tmp/racktables-RackTables-0.22.0 /var/www/html && \
#    rm /tmp/racktables.tar.gz

RUN curl -sSL https://github.com/RackTables/racktables/archive/RackTables-0.22.0.tar.gz -o /tmp/racktables.tar.gz && \
    tar -xzf /tmp/racktables.tar.gz -C /tmp && \
    mv /tmp/racktables-RackTables-0.22.0 /var/www/html/racktables && \
    ln -s /var/www/html/racktables/wwwroot /var/www/html/wwwroot && \
    rm /tmp/racktables.tar.gz
    #touch /var/www/html/racktables/wwwroot/inc/secret.php
    #chmod a=rw /var/www/html/racktables/wwwroot/inc/secret.php
    #chmod 440 /var/www/html/racktables/wwwroot/inc/secret.php && \
    #chown www-data:www-data /var/www/html/racktables/wwwroot/inc/secret.php




# Copy your Nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Expose HTTP port
EXPOSE 80

# Start both PHP-FPM and Nginx
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
