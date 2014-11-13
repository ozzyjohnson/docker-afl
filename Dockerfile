FROM debian:wheezy

MAINTAINER Ozzy Johnson <docker@ozzy.io>

ENV DEBIAN_FRONTEND noninteractive

ENV AFL_INSTALL http://lcamtuf.coredump.cx/soft/afl.tgz
ENV LIBJPEG_TURBO_INSTALL svn://svn.code.sf.net/p/libjpeg-turbo/code/branches/1.3.x

# Update and install minimal.
#
# afl:
#   build-essential, wget
#
# lidjpeg-turbo:
#   autoconf, automake, build-essential, libtool, nasm,
#   subversion, wget

RUN \
    apt-get update \
        --quiet \
    && apt-get install \
        --yes \
        --no-install-recommends \
        --no-install-suggests \
    autoconf=2.69-1 \
    automake=1:1.11.6-1 \
    gcc=4:4.7.2-1 \
    libtool=2.4.2-1.1 \
    make=3.81-8.2 \
    nasm=2.10.01-1 \
    subversion=1.6.17dfsg-4+deb7u6 \
    wget=1.13.4-3+deb7u2 \

# Clean up packages.
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Get and build AFL.
RUN \
    wget \
    $AFL_INSTALL \
        --no-verbose \
    && mkdir afl-src \
    && tar -xzf afl.tgz -C afl-src --strip-components=1 \
    && cd afl-src \
    && sed -i 's/^\/\/ #define USE_64BIT/#define USE_64BIT/gI' config.h \
    && make -j`getconf _NPROCESSORS_ONLN` \
    && make install \
    && rm -rf \
        /tmp/afl.tgz \
        /tmp/afl-src

# Get and build libjpeg-turbo.
RUN \
    svn \
        -q \
        co \
        $LIBJPEG_TURBO_INSTALL \
        libjpeg-turbo \
    && cd libjpeg-turbo \
    && autoreconf -fiv \
    && CC=/usr/local/bin/afl-gcc ./configure \
    && make -j`getconf _NPROCESSORS_ONLN` \
    && make install \
    && rm -rf /tmp/libjpeg-turbo

VOLUME ["/data"]

WORKDIR /data

CMD ["bash"]
