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

# import ppa sources
RUN apt-get -q update
RUN apt-get -qy install git build-essential software-properties-common
RUN for repo in \
        nginx/development chris-lea/node.js ubuntu-toolchain-r/test; \
    do add-apt-repository -y ppa:$repo; done

# enable multiverse
RUN sed -i 's/universe$/universe multiverse/g' /etc/apt/sources.list

# checkout cling, clang & llvm sources
RUN git clone http://root.cern.ch/git/llvm.git  -b cling-patches --depth=1
WORKDIR ./llvm/tools
RUN git clone http://root.cern.ch/git/clang.git -b cling-patches --depth=1
RUN git clone http://root.cern.ch/git/cling.git --depth=1
WORKDIR ../

# build llvm with cling while installing other packages via apt
RUN apt-get -q update && apt-get -qy install \
        nginx screen tmux git zsh vim curl netcat \
        aptitude apt-file man-db manpages-posix-dev \
        nodejs python-pip python3-pip ruby2.0 rake php5 \
        nasm golang racket haskell-platform cmake gdb \
        gcc-5 gcc-arm-linux-gnueabi gcc-arm-linux-gnueabihf \
        gdb-mingw-w64-target gcc-mingw-w64-i686 gcc-mingw-w64-x86-64 & \
    ./configure --prefix=/usr/local --disable-assertions \
        --enable-optimized --enable-targets=host-only && \
    make -j `nproc` && make install
WORKDIR ../

# import dotfiles
RUN curl -fsSL 'https://static.rust-lang.org/rustup.sh' | sh
RUN curl -fsSL 'https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh' | bash
RUN chsh -s /bin/zsh
RUN sed -i 's/^ZSH_THEME="robbyrussell"$/ZSH_THEME="af-magic"/' ~/.zshrc
RUN sed -i 's/archive/cn.archive/g' /etc/apt/sources.list
RUN git clone https://github.com/Arnie97/dotfiles
RUN cp dotfiles/.gitconfig dotfiles/.vimrc ~/

# import config files
COPY forward /usr/local/bin
COPY readcolor.conf /etc/nginx/conf.d
COPY alive /etc/cron.daily

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
RUN chown -R www-data:www-data /var/lib/nginx

# clean up
RUN rm -rf llvm chisel.tgz dotfiles ${PATH_NAME} /var/lib/apt/lists/*

CMD ["/bin/sh", "-c", "/usr/local/bin/forward"]
EXPOSE 8080
