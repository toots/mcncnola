FROM alpine:3.12 AS build
MAINTAINER toots@rastageeks.org

RUN apk update && \
    apk --no-cache add \
    git \
    gcc \
    g++ \
    jack-dev \
    fftw-dev \
    libsndfile-dev \
    cmake \
    make \
    alsa-lib-dev \
    eudev-dev \
    linux-headers \
    bsd-compat-headers \
    readline-dev

COPY .git /tmp/.git
COPY supercollider /tmp/supercollider

# Bump Link to more recent commit than current release of 3.0.2 and update submodules
# This resolves an underlying ASIO compile bug that was fixed upstream
RUN cd /tmp/supercollider/external_libraries/link && git checkout 0b77cc2 && git submodule update

RUN mkdir /tmp/supercollider/build

WORKDIR /tmp/supercollider/build

ARG CC=/usr/bin/gcc
ARG CXX=/usr/bin/g++

RUN cmake -L \
      -DCMAKE_BUILD_TYPE="Release" \
      -DBUILD_TESTING=OFF \
      -DENABLE_TESTSUITE=OFF \
      -DSUPERNOVA=OFF \
      -DNATIVE=OFF \
      -DSSE=OFF \
      -DSSE2=OFF \
      -DSC_IDE=OFF \
      -DSC_QT=OFF \
      -DSC_ED=OFF \
      -DSC_EL=OFF \
      -DINSTALL_HELP=OFF \
      -DSC_VIM=ON \
      -DNO_AVAHI=ON \
      -DNO_X11=ON \
      .. \
      && make -j $(nproc) \
      && make install

COPY sc3-plugins /tmp/sc3-plugins

RUN mkdir /tmp/sc3-plugins/build

WORKDIR /tmp/sc3-plugins/build

RUN cmake -L \
      -DCMAKE_BUILD_TYPE="Release" \
      -DSUPERNOVA=OFF \
      -DNATIVE=OFF \
      -DSC_PATH=/tmp/supercollider/ \
      .. \
      && make -j $(nproc) \
      && make install

COPY FoxDot /tmp/FoxDot
COPY Troop /tmp/Troop
COPY *.scd /tmp
COPY jack-matchmaker.conf /tmp/jack-matchmaker.conf
COPY wlanstart.sh /tmp/wlanstart.sh

RUN mkdir -p /tmp/data/include && \
    mkdir -p /tmp/data/share &&\
    mkdir -p /tmp/data/lib && \
    mkdir -p /tmp/data/bin && \
    mkdir -p /tmp/data/mcncnola && \
    cp -rf /usr/local/include/SuperCollider /tmp/data/include && \
    cp -rf /usr/local/share/SuperCollider /tmp/data/share && \
    cp -rf /usr/local/lib/SuperCollider /tmp/data/lib && \
    cp -rf /usr/local/bin/scsynth /tmp/data/bin && \
    cp -rf /usr/local/bin/sclang /tmp/data/bin && \
    cp -rf /tmp/wlanstart.sh /tmp/data/bin && \
    cp -rf /tmp/*.scd /tmp/data/mcncnola && \
    cp -rf /tmp/FoxDot /tmp/data/mcncnola && \
    cp -rf /tmp/Troop /tmp/data/mcncnola && \
    cp -rf /tmp/jack-matchmaker.conf /tmp/data/mcncnola/jack-matchmaker.conf

FROM alpine:3.12

WORKDIR /root

COPY --from=build /tmp/data /usr/local

RUN apk update && apk --no-cache add \
    bash \
    hostapd \
    iptables \
    dhcp \
    docker \
    iproute2 \
    iw \
    xvfb \
    git \
    jack \
    python3 \
    python3-tkinter \
    py3-pip \
    py3-setuptools \
    eudev \
    fftw \
    libsndfile \
    linux-pam \
    readline && \
    echo "" > /var/lib/dhcp/dhcpd.leases && \
    cd /usr/local/mcncnola/FoxDot && \
    python3 setup.py install && \
    sclang /usr/local/mcncnola/setup.scd && \
    mkdir -p /root/.config/SuperCollider && \
    cp /usr/local/mcncnola/startup.scd /root/.config/SuperCollider/startup.scd && \
    pip3 install jack-matchmaker
