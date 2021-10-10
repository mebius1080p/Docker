#!/bin/bash
set -euo pipefail

# helper script for apache update

APACHE_VERSION="2.4.51"

# prepare spec file
cd ~/ \
&& mkdir -p download \
&& cd ~/download \
&& wget https://www-eu.apache.org/dist/httpd/httpd-${APACHE_VERSION}.tar.bz2 \
&& tar xvf httpd-${APACHE_VERSION}.tar.bz2

# rename current httpd.spec to compare and fix
cd ~/docker/apache/spec \
&& mv httpd.spec httpd.spec.old \
&& cp ~/download/httpd-${APACHE_VERSION}/httpd.spec ~/docker/apache/spec

# ここで httpd.spec を調整する
# バージョン確認、必要な行を追加する
# 作業が終わったら
# rm ~/docker/apache/spec/httpd.spec.old
# 第一段階終了
