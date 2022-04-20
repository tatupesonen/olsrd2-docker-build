# syntax=docker/dockerfile:1
FROM debian:buster as deps

# Build deps for OONF
RUN apt-get update -qq && \
    apt-get -y -qq install \
    gcc-8 \
    cmake \
    make \
    libnl-3-dev \
    curl

# Download stage
FROM deps as download

# Version
ARG OONF_VERS=0.15.1
WORKDIR /oonf
RUN curl -L https://github.com/OLSR/OONF/archive/refs/tags/v${OONF_VERS}.tar.gz > oonf-v${OONF_VERS}.tar.gz \
    && tar --strip-components=1 -xvzf oonf-v${OONF_VERS}.tar.gz

# Build stage
from download as build
WORKDIR /oonf/build

# Build env
ARG CFLAGS="-Wno-error=format-truncation"

# Build
RUN cmake \
    -D OONF_LIB_GIT:String=v${OONF_VERS}-archive \
    -D OONF_VERS=String=${OONF_VERS} \
    -D OONF_LOGGING_LEVEL=debug \
    -D CMAKE_BUILD_TYPE:String=Release .. \
    && make -s olsrd2_static \
    && make install
