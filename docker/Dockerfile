# base image
FROM ubuntu:20.04

# docker image arguments
ARG AARCH64_TOOLCHAIN_LINK=https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/12.3.rel1/binrel/arm-gnu-toolchain-12.3.rel1-x86_64-aarch64-none-elf.tar.xz

# Install base dependencies
RUN apt-get update && apt-get install -y \
        git \
        curl \
        wget \
        xz-utils \
        build-essential \
        gcc-multilib \
        python3 \
        python3-pip \
        yamllint \
        pylint \
        nodejs \
        npm \
        enchant-2 \
        software-properties-common \
        ninja-build \
        pkg-config \
        libglib2.0-dev \
        libpixman-1-dev \
        libslirp-dev \
        bison \
        flex \
        tree \
        vim \
        nano \
        device-tree-compiler \
        cpio \
        unzip \
        rsync \
        bc

# Install python packages
RUN pip3 install \
        gitlint \
        pydevicetree


# Install toolchains
RUN mkdir /opt/aarch64-toolchain && curl $AARCH64_TOOLCHAIN_LINK | tar xJ -C /opt/aarch64-toolchain --strip-components=1

# Add generic non-root user
RUN addgroup bao && adduser -disabled-password --ingroup bao bao

# setup environment
ENV PATH=$PATH:/opt/aarch64-toolchain/bin

# default startup command
CMD /bin/bash