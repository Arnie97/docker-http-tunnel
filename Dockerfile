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

# import ppa sources
RUN apt-get update -q
RUN apt-get install -y software-properties-common
RUN for repo in \
        nginx/development chris-lea/node.js ubuntu-toolchain-r/test; \
    do add-apt-repository -y ppa:$repo; done
RUN sed -i 's/universe$/universe multiverse/g' /etc/apt/sources.list

# install packages
RUN apt-get update -q
RUN apt-get install -y \
    nginx screen tmux git zsh vim curl netcat \
    aptitude apt-file man-db manpages-posix-dev \
    build-essential gcc-5 cmake haskell-platform \
    python-pip python3-pip ruby ruby2.0 nodejs

# configure dotfiles
RUN chsh -s /bin/zsh
RUN curl -fsSL 'https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh' | bash
RUN git clone https://github.com/Arnie97/dotfiles
RUN cp dotfiles/.gitconfig dotfiles/.vimrc ~/
RUN sed -i 's/^ZSH_THEME="robbyrussell"$/ZSH_THEME="af-magic"/' ~/.zshrc
RUN chown -R www-data:www-data /var/lib/nginx

# checkout cling, clang & llvm sources
RUN git clone http://root.cern.ch/git/llvm.git  -b cling-patches --depth=1
WORKDIR ./llvm/tools
RUN git clone http://root.cern.ch/git/clang.git -b cling-patches --depth=1
RUN git clone http://root.cern.ch/git/cling.git --depth=1
WORKDIR ../

# build llvm with cling
RUN ./configure --enable-optimized --enable-targets=host-only --disable-assertions --prefix=/usr/local
RUN make -j `nproc`
RUN make install
WORKDIR ../

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# clean up
RUN rm -rf llvm chisel.tgz dotfiles ${PATH_NAME} /var/lib/apt/lists/*

# import config files
COPY forward /usr/local/bin
COPY readcolor.conf /etc/nginx/conf.d
COPY alive /etc/cron.daily
RUN sed -i 's/archive/cn.archive/g' /etc/apt/sources.list

CMD ["/bin/sh", "-c", "/usr/local/bin/forward"]
EXPOSE 8080
