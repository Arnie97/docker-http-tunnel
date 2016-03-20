FROM rastasheep/ubuntu-sshd:latest
MAINTAINER Arnie97 <arnie97@gmail.com>

ENV CHISEL_VERSION 1.1.3
ENV CHISEL_ARCH    linux_amd64
ENV COW_VERSION    0.9.6
ENV COW_ARCH       linux64

# install the chisel http tunnel
WORKDIR /tmp
ENV PATH_NAME chisel_${CHISEL_VERSION}_${CHISEL_ARCH}
RUN wget   -O chisel.tgz https://github.com/jpillora/chisel/releases/download/${CHISEL_VERSION}/${PATH_NAME}.tar.gz
RUN tar -xzvf chisel.tgz ${PATH_NAME}/chisel
RUN mv ${PATH_NAME}/chisel /usr/local/bin

# install cow
ENV PATH_NAME cow-${COW_ARCH}-${COW_VERSION}
RUN wget -O cow.gz "http://dl.chenyufei.info/cow/${COW_VERSION}/${PATH_NAME}.gz"
RUN gunzip cow.gz
RUN chmod +x cow
RUN mv cow /usr/local/bin

# add a startup script
COPY forward /usr/local/bin

CMD ["/bin/sh", "-c", "/usr/local/bin/forward"]
EXPOSE 8080
