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

# set current user 
RUN groupmod -g ${HOST_UID} ubuntu && \
    usermod -u ${HOST_UID} ubuntu && \
    echo "ubuntu:1234" | chpasswd 
# setup z shell and oh-my-zsh
ENV ZSH_CUSTOM=/home/ubuntu/.oh-my-zsh/custom
RUN export ZSH=/home/ubuntu/.oh-my-zsh && \
    echo "y" | sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
# install useful tools for command-line
RUN apt-get update && apt-get install -y fzf bat fd-find silversearcher-ag && apt-get clean && apt-get autoclean && \
    wget https://github.com/AlDanial/cloc/releases/download/v2.00/cloc-2.00.tar.gz && tar zxvf cloc*.tar.gz -C /opt && rm -rf cloc*.tar.gz && \
    wget https://github.com/jesseduffield/lazygit/releases/download/v0.43.1/lazygit_0.43.1_Linux_x86_64.tar.gz && tar zxvf lazygit*.tar.gz -C /opt && \
    tar zxvf lazygit*.tar.gz && mv lazygit /usr/local/bin && cd /opt && rm LICENSE README.md lazygit*
ENV PATH="/opt/cloc-2.00:$PATH"

# create "workspace" directory
RUN mkdir /home/ubuntu/workspace && \
    chown -R ${HOST_UID}:${HOST_UID} /home/ubuntu

# mark /home/ubuntu/workspace as mount point
VOLUME /home/ubuntu/workspace

# specify work-dir and user
WORKDIR /home/ubuntu/workspace
USER ubuntu
# set container's entrypoint as a infinite process
ENTRYPOINT ["tail"]
CMD ["-f","/dev/null"]
