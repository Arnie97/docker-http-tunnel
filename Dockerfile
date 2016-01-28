FROM rastasheep/ubuntu-sshd:latest
MAINTAINER Arnie97 <arnie97@gmail.com>
ENV VERSION 1.1.3
ENV ARCH amd64

# install the chisel http tunnel
WORKDIR /tmp
ENV PATH_NAME chisel_${VERSION}_linux_${ARCH}
RUN wget   -O chisel.tgz https://github.com/jpillora/chisel/releases/download/${VERSION}/${PATH_NAME}.tar.gz
RUN tar -xzvf chisel.tgz ${PATH_NAME}/chisel
RUN mv ${PATH_NAME}/chisel /usr/local/bin

# install nginx
RUN apt-get update -q
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update -q
RUN apt-get install -y nginx
RUN chown -R www-data:www-data /var/lib/nginx

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# clean up
RUN rm -rf ${PATH_NAME} /var/lib/apt/lists/*

# add a startup script
COPY forward /usr/local/bin

CMD ["/bin/sh", "-c", "/usr/local/bin/forward"]
EXPOSE 8080
