#!/bin/sh

cd
tar -Jcvf letsencrypt.tar.xz /etc/letsencrypt
mv letsencrypt.tar.xz scripts