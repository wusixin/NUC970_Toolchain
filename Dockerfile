FROM debian:buster

# Metadata Params
ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

# Metadata
LABEL \
	org.label-schema.schema-version="1.0" \
	org.label-schema.vendor="wusixin" \
	org.label-schema.name="wusixin/nuc970_toolchain" \
	org.label-schema.description="Cross C/C++ Toolchain for NUC970" \
	org.label-schema.url="https://github.com/wusixin/NUC970_Toolchain" \
	org.label-schema.vcs-url="https://github.com/wusixin/NUC970_Toolchain.git" \
	org.label-schema.build-date=$BUILD_DATE \
	org.label-schema.vcs-ref=$VCS_REF \
	org.label-schema.version=$BUILD_VERSION \
	org.label-schema.docker.cmd="docker run -it --rm -v ${pwd}:/work wusixin/NUC970_Toolchain"

# Environment Variable
ENV DEBIAN_FRONTEND=noninteractive
ENV WORKDIR=/work

RUN apt-get update && apt-get install -y \
    locales \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg-agent \
    software-properties-common

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libbz2-dev \
    cmake

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    libc6:i386 \
    libncurses5:i386 \
    libstdc++6:i386 \
    lib32z1 \
    libbz2-1.0:i386 \
    liblzma5:i386

# download a release from github
RUN wget -q https://github.com/sensors-link/NUC970_Toolchain/releases/download/v1.0.0/arm_linux_4.8.tar.gz \
    && wget -q https://github.com/sensors-link/NUC970_Toolchain/releases/download/v1.0.0/toolchain_install.sh \
    && chmod +x toolchain_install.sh \
    && ./toolchain_install.sh \
    && rm arm_linux_4.8.tar.gz \
    && rm toolchain_install.sh

RUN wget -q https://mirrors.edge.kernel.org/pub/linux/kernel/v3.x/linux-3.10.108.tar.xz \
    && tar -xJf linux-3.10.108.tar.xz \
    && cp -r linux-3.10.108/include/linux /usr/local/arm_linux_4.8/usr/include/ \
    && rm -fr linux-3.10.108.tar.xz linux-3.10.108

RUN echo "crosstool" >> /etc/hostname

# Set System Locales
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set Volume and Workdir
RUN mkdir -p "${WORKDIR}" && chmod -R 777 "$WORKDIR"
VOLUME ${WORKDIR}
WORKDIR ${WORKDIR}

# Bash Settings
RUN echo "export HISTTIMEFORMAT='%d/%m/%y %T '" >> ~/.bashrc && \
    echo "export PATH=/usr/local/arm_linux_4.8/bin:\$PATH" >> ~/.bashrc && \
    echo "export PS1='\[\e[0;36m\]\u\[\e[0m\]@\[\e[0;33m\]\h\[\e[0m\]:\[\e[0;35m\]\w\[\e[0m\]\$ '" >> ~/.bashrc && \
    echo "alias ll='ls -lah'" >> ~/.bashrc && \
    echo "alias ls='ls --color=auto'" >> ~/.bashrc

CMD ["/bin/bash"]