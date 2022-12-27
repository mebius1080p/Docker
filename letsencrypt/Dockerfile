FROM quay.io/centos/centos:stream9
LABEL maintainer="mebius"

RUN echo "ip_resolve=4" >> /etc/yum.conf \
	&& yum update -y \
	&& yum install epel-release -y \
	&& yum install certbot openssl -y \
	&& yum clean all

CMD ["/bin/bash"]
