FROM debian:wheezy

MAINTAINER Ozzy Johnson <docker@ozzy.io>

ENV REFRESHED_AT 2016-03-05

ENV DEBIAN_FRONTEND noninteractive

ENV AFL_INSTALL http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz
ENV LIBJPEG_TURBO_INSTALL svn://svn.code.sf.net/p/libjpeg-turbo/code/branches/1.4.x

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
    autoconf \
    automake \
    gcc \
    libtool \
    make \
    nasm \
    subversion \
    wget \

# Clean up packages.
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Get ready to build.
WORKDIR /tmp

# Get and build AFL.
RUN \
    wget \
    $AFL_INSTALL \
        --no-verbose \
    && mkdir afl-src \
    && tar -xzf afl-latest.tgz \
        -C \
        afl-src \
        --strip-components=1 \
    && cd afl-src \
    && sed -i 's/^\/\/ #define USE_64BIT/#define USE_64BIT/gI' config.h \
    && make \
    && make install \
    && rm -rf \
        /tmp/afl-latest.tgz \
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
