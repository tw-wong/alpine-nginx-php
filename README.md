# alpine-nginx-php
Build a docker image with Nginx and PHP on Alpine Linux.

When the container is running, start `Supervisord` in the foreground and use it to manage the Nginx, PHP-FPM process in the container.


## Linux
Alpine: 3.12
## Packages
* Supervisord: 4.2.0
* Nginx: 1.18.0
* PHP: 7.3.26
* PHP-FPM: 7.3.26

## How to build an image
```
$ git clone git@github.com:tw-wong/alpine-nginx-php.git
$ cd alpine-nginx-php/
$ docker build -t tw-wong/alpine-web:latest .
```

## Verify docker image
```
$ alpine-nginx-php git:(master) ✗ docker images | grep alpine
tw-wong/alpine-web                                               latest    97dea4c9dce0   2 minutes ago   82MB
```

## How to start container
```
$ docker run --rm -p 80:80 --name alpine-web tw-wong/alpine-web:latest
```

## How to access container
```
$ docker exec -it alpine-web /bin/sh
```

## How to check process in container
```
/var/www/html # ps aux
PID   USER     TIME  COMMAND
    1 root      0:00 {supervisord} /usr/bin/python3 /usr/bin/supervisord -c /etc/supervisor.d/supervisord.ini
    8 root      0:00 nginx: master process nginx -c /etc/nginx/nginx.conf -g daemon off;
    9 root      0:00 {php-fpm7} php-fpm: master process (/etc/php7/php-fpm.conf)
   10 nginx     0:00 nginx: worker process
   11 nginx     0:00 nginx: worker process
   12 nginx     0:00 nginx: worker process
   13 nginx     0:00 nginx: worker process
   14 nginx     0:00 nginx: worker process
   15 nginx     0:00 nginx: worker process
   16 nginx     0:00 {php-fpm7} php-fpm: pool www
   17 nginx     0:00 {php-fpm7} php-fpm: pool www
   18 root      0:00 /bin/sh
   26 root      0:00 ps aux
```

Note:
* `Supervisord` process is run under root user.
* `Nginx` and `PHP-FPM` master process is also run under root user (managed by `Supervisord`).
* `Nginx` and `PHP-FPM` workers are run under nginx user (managed by `Nginx` and `PHP-FPM` service respectively, not by `Supervisord`).

## Config and version checking
```
# Check Alpine version
/var/www/html # cat /etc/os-release
NAME="Alpine Linux"
ID=alpine
VERSION_ID=3.12.3
PRETTY_NAME="Alpine Linux v3.12"
HOME_URL="https://alpinelinux.org/"
BUG_REPORT_URL="https://bugs.alpinelinux.org/"


# Check Nginx version
/var/www/html # nginx -v
nginx version: nginx/1.18.0


# Check PHP version
/var/www/html # php -v
PHP 7.3.26 (cli) (built: Jan  7 2021 13:20:58) ( NTS )
Copyright (c) 1997-2018 The PHP Group
Zend Engine v3.3.26, Copyright (c) 1998-2018 Zend Technologies
    with Zend OPcache v7.3.26, Copyright (c) 1999-2018, by Zend Technologies


# Check PHP-FPM version
/var/www/html # php-fpm7 -v
PHP 7.3.26 (fpm-fcgi) (built: Jan  7 2021 13:20:58)
Copyright (c) 1997-2018 The PHP Group
Zend Engine v3.3.26, Copyright (c) 1998-2018 Zend Technologies
    with Zend OPcache v7.3.26, Copyright (c) 1999-2018, by Zend Technologies
    
# Nginx config test
/var/www/html # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

# PHP-FPM config test
/var/www/html # php-fpm7 -t
[14-Jan-2021 08:44:50] NOTICE: configuration file /etc/php7/php-fpm.conf test is successful
```

## How to test PHP script

1. Create php scipt in container.
```
# Create public dir and index.php
/var/www/html # mkdir public
/var/www/html # cd public/
/var/www/html/public # touch index.php
/var/www/html/public # echo "<?php echo phpinfo(); ?>" >> index.php
```

2. Enter `http://localhost` from your browser, you should see the `phpinfo()` page.

## Supervisord command:
```
# When change config of: /etc/supervisor.d/supervisord.ini
# make the changes into effect.
/var/www/html # supervisorctl reread
/var/www/html # supervisorctl update

# Restart Nginx process (same as other command like start, stop, restart).
/var/www/html # supervisorctl
supervisor> restart nginx

# Restart PHP-FPM
/var/www/html # supervisorctl
supervisor> restart php-fpm

# Check the status of all the register program that manage by Supervisord
/var/www/html # supervisorctl
supervisor> status

# Quit supervisorctl
/var/www/html # supervisorctl
supervisor> quit
```

## Refs:
* https://dev.to/jackmiras/laravel-with-php7-4-in-an-alpine-container-3jk6
* https://www.digitalocean.com/community/tutorials/how-to-install-and-manage-supervisor-on-ubuntu-and-debian-vps
* https://hangarau.space/using-supervisord-as-the-init-process-of-a-docker-container/
* https://www.cyberciti.biz/faq/how-to-install-php-7-fpm-on-alpine-linux/
* https://techviewleo.com/install-nginx-with-php-fpm-on-alpine-linux/
* https://bobcares.com/blog/php-fpm-sock-failed-13-permission-denied/
* https://gist.github.com/tsabat/1528270
