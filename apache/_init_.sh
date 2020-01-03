#!/bin/bash

# volume でマウントしたディレクトリパーミッション問題に対処
chmod 777 /var/run/php-fpm

/usr/bin/supervisord
