FROM ubuntu:latest

# ARGs
ARG BASIC="zsh fish sudo git vim build-essential curl wget tar unzip make cmake \
    gtkwave libreadline-dev x11-utils x11-apps man-db python3 python3-pip \
    clangd clang-format software-properties-common valgrind"
# the HOST_UID is also used as GID
ARG HOST_UID

# Basic setup (including helix editor)
ENV TZ="Asia/Taipei"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# RUN yes | unminimize && \ ## Ps: The "unminimize" command is no more needed after ubuntu:24.04
RUN apt-get update && \
    apt-get -y install ${BASIC} && \
    apt-add-repository ppa:maveonair/helix-editor && apt-get update && apt-get install -y helix && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
# Install Zellij (alternative to Tmux)
RUN wget https://github.com/zellij-org/zellij/releases/download/v0.40.1/zellij-x86_64-unknown-linux-musl.tar.gz && \
    tar xvf zellij*.tar.gz && mv zellij /usr/local/bin && \
    rm zellij*.tar.gz

# change password of built-in ubuntu user
RUN echo "ubuntu:1234" | chpasswd
# install useful tools for command-line
RUN apt-get update && apt-get install -y fzf bat fd-find silversearcher-ag && apt-get clean && apt-get autoclean && \
    wget https://github.com/AlDanial/cloc/releases/download/v2.00/cloc-2.00.tar.gz && tar zxvf cloc*.tar.gz -C /opt && rm -rf cloc*.tar.gz && \
    wget https://github.com/jesseduffield/lazygit/releases/download/v0.43.1/lazygit_0.43.1_Linux_x86_64.tar.gz && tar zxvf lazygit*.tar.gz -C /opt && \
    tar zxvf lazygit*.tar.gz && mv lazygit /usr/local/bin && cd /opt && rm LICENSE README.md lazygit*
ENV PATH="/opt/cloc-2.00:$PATH"

# create "workspace" directory
RUN mkdir /home/ubuntu/workspace && \
    chown -R ubuntu:ubuntu /home/ubuntu/workspace

# mark /home/ubuntu/workspace as mount point
VOLUME /home/ubuntu/workspace

# specify work-dir and user
USER ubuntu
WORKDIR /home/ubuntu/workspace
# set container's entrypoint as a infinite process
ENTRYPOINT ["tail"]
CMD ["-f","/dev/null"]
