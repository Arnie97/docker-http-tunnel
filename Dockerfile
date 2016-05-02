FROM rastasheep/ubuntu-sshd:latest
MAINTAINER Arnie97 <arnie97@gmail.com>
ENV VERSION 1.1.3
ENV ARCH amd64

# install the chisel http tunnel
WORKDIR /tmp
ENV PATH_NAME chisel_${VERSION}_linux_${ARCH}
RUN wget  -qO chisel.tgz https://github.com/jpillora/chisel/releases/download/${VERSION}/${PATH_NAME}.tar.gz
RUN tar -xzvf chisel.tgz ${PATH_NAME}/chisel
RUN mv ${PATH_NAME}/chisel /usr/local/bin

# install prerequisite packages
RUN apt-get -q update
RUN apt-get -qy install git build-essential

# build llvm with cling while installing other packages
RUN install_packages & build_llvm

# import config files
COPY forward /usr/local/bin
COPY readcolor.conf /etc/nginx/conf.d
COPY alive /etc/cron.daily

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
RUN chown -R www-data:www-data /var/lib/nginx

# clean up
RUN rm -rf /tmp/* /var/lib/apt/lists/*

CMD ["/bin/sh", "-c", "/usr/local/bin/forward"]
EXPOSE 8080
