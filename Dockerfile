FROM debian:wheezy

MAINTAINER Ozzy Johnson <docker@ozzy.io>

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /tmp

# Update and install minimal.
# autoconf, automake, libtool - For building libjpeg-turbo.
RUN apt-get update \
     --quiet \
    && apt-get \
       install \
         --yes \
         --no-install-recommends \
         --no-install-suggests \
       autoconf \
       automake \
       build-essential \
       libtool \
       nasm \
       subversion \
       wget \

# Clean up packages.
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Get and build AFL.
RUN wget http://lcamtuf.coredump.cx/soft/afl.tgz \
      --no-verbose \
      && mkdir afl-src \
      && tar -xzf afl.tgz -C afl-src --strip-components=1 \
      && cd afl-src \
      && sed -i 's/^\/\/ #define USE_64BIT/#define USE_64BIT/gI' config.h \
      && make \
      && make install \
      && rm -rf /tmp/afl.tgz \
                /tmp/afl-src

# Get and build libjpeg-turbo.
RUN svn -q co \
      svn://svn.code.sf.net/p/libjpeg-turbo/code/branches/1.3.x \
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
