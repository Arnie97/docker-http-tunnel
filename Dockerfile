FROM alpine
MAINTAINER Arnie97 <arnie97@gmail.com>
ENV VERSION 1.1.3
ENV ARCH amd64

# install and configure ssh server
RUN apk update && apk add openssl openssh
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN ssh-keygen -A
RUN echo 'root:password' | chpasswd

# install the chisel http tunnel
WORKDIR /tmp
ENV PATH_NAME chisel_${VERSION}_linux_${ARCH}
RUN wget   -O chisel.tgz https://github.com/jpillora/chisel/releases/download/${VERSION}/${PATH_NAME}.tar.gz
RUN tar -xzvf chisel.tgz ${PATH_NAME}/chisel
RUN mv ${PATH_NAME}/chisel /usr/local/bin

# clean up
RUN apk del openssl
RUN rm -rf ${PATH_NAME}

# add a startup script
WORKDIR /usr/local/bin
RUN echo '#!/bin/sh'          >> forward
RUN echo '/usr/sbin/sshd -D&' >> forward
RUN echo 'chisel server'      >> forward
RUN chmod +x                     forward

CMD ["/bin/sh", "-c", "/usr/local/bin/forward"]
EXPOSE 8080
