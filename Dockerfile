# syntax=docker/dockerfile:1
FROM debian:buster as deps

# Build deps for OONF
RUN apt-get update -qq \
    && apt-get -y -qq install \
    gcc-8 \
    cmake \
    make \
    libnl-3-dev \
    curl \
    net-tools

FROM deps as build
LABEL AUTHOR="Tatu Pesonen (tatu@narigon.dev)"

# Version
ARG OONF_VERSION=0.15.1
ARG IFACE=eth0
ENV OONF_VERSION=${OONF_VERSION}
ENV IFACE=${IFACE}

# Build env
ENV CFLAGS="-Wno-error=format-truncation"
WORKDIR /oonf

RUN curl -L https://github.com/OLSR/OONF/archive/refs/tags/v${OONF_VERSION}.tar.gz > oonf-v${OONF_VERSION}.tar.gz \
    && tar --strip-components=1 -xvzf oonf-v${OONF_VERSION}.tar.gz

WORKDIR /oonf/build
RUN cmake \
    -D OONF_LIB_GIT:String=v${OONF_VERSION}-archive \
    -D OONF_VERSION=String=${OONF_VERSION} \
    -D OONF_LOGGING_LEVEL=debug \
    -D CMAKE_BUILD_TYPE:String=Release .. \
    && make \
    && make install

ENTRYPOINT ./olsrd2_static eth0
