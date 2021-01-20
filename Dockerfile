FROM alpine:3.12

WORKDIR /var/www/html/

RUN echo "UTC" > /etc/timezone
RUN apk add --no-cache zip unzip curl nginx supervisor npm

# Installing bash
# RUN apk add bash
# RUN sed -i 's/bin\/ash/bin\/bash/g' /etc/passwd

# Installing PHP
RUN apk add --no-cache php \
    php-common \
    php-fpm \
    php-pdo \
    php-opcache \
    php-zip \
    php-phar \
    php-iconv \
    php-cli \
    php-curl \
    php-openssl \
    php-mbstring \
    php-tokenizer \
    php-fileinfo \
    php-json \
    php-xml \
    php-xmlwriter \
    php-simplexml \
    php-dom \
    php-pdo_mysql \
    php-pdo_sqlite \
    php-tokenizer \
    php7-pecl-redis
    
# Installing composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

# Backup supervisord, php-fpm, nginx config
RUN cp /etc/supervisord.conf /etc/supervisord.conf_backup
RUN cp /etc/php7/php-fpm.conf /etc/php7/php-fpm.conf_backup
RUN cp /etc/php7/php-fpm.d/www.conf /etc/php7/php-fpm.d/www_conf_backup
RUN cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf_backup
RUN cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default_conf

# Configure supervisor
RUN mkdir -p /etc/supervisor.d/
COPY config/supervisord.conf /etc/supervisord.conf
COPY config/supervisord.ini /etc/supervisor.d/supervisord.ini

# Configure php-fpm
RUN mkdir -p /run/php/
RUN touch /run/php/php7.3-fpm.pid
RUN touch /run/php/php7.3-fpm.sock
COPY config/php-fpm.conf /etc/php7/php-fpm.conf
COPY config/php-fpm.www.conf /etc/php7/php-fpm.d/www.conf

# Configure nginx
#RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY config/nginx_default.conf /etc/nginx/conf.d/default.conf
COPY config/fastcgi-php.conf /etc/nginx/fastcgi-php.conf

RUN mkdir -p /run/nginx/
RUN touch /run/nginx/nginx.pid

# Create symbolic link of the Alpine standard output has to gets 
# created at /var/log/nginx/access.log. 
# This configuration, as mentioned in the Supervisor sections, 
# is what allows us to see NGINX logs from containers.
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Container execution
EXPOSE 80
CMD ["supervisord", "-c", "/etc/supervisor.d/supervisord.ini"]
# CMD ["supervisord", "-c", "/etc/supervisord.conf"]