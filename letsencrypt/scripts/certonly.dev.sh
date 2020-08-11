#!/bin/sh

certbot certonly \
 --dry-run \
 --agree-tos \
 --email $LETS_EMAIL \
 --webroot \
 -n \
 -d $LETS_DOMAIN \
 -w $WEB_ROOT \
 --preferred-chain "DST Root CA X3" \
 -vvv
