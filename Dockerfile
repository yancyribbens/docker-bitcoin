FROM ubuntu:18.04
maintainer yancy ribbens "yancy.ribbens@gmail.com"

RUN apt-get update -qq && apt-get install -y \
    git \
    wget \
    build-essential \
    libtool \
    autotools-dev \
    automake \
    pkg-config \
    libssl-dev \
    libevent-dev \
    bsdmainutils \
    python3 \
    libboost-all-dev

# Checkout bitcoin source
RUN mkdir /bitcoin-source
WORKDIR /bitcoin-source
RUN git clone https://github.com/bitcoin/bitcoin.git

# Install Berkley Database
RUN wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
RUN tar -xvf db-4.8.30.NC.tar.gz
WORKDIR /bitcoin-source/db-4.8.30.NC/build_unix
RUN mkdir -p build
RUN BDB_PREFIX=$(pwd)/build
RUN ../dist/configure --disable-shared --enable-cxx --with-pic --prefix=$BDB_PREFIX
RUN make install

# install bitcoin 0.16.3
WORKDIR /bitcoin-source/bitcoin
RUN git checkout tags/v0.16.3
RUN ./autogen.sh
RUN ./configure CPPFLAGS="-I${BDB_PREFIX}/include/ -O2" LDFLAGS="-L${BDB_PREFIX}/lib/" --without-gui
RUN make
RUN make install

# configure bitcoin network
ARG NETWORK=regtest
ARG RPC_USER=foo
ARG RPC_PASSWORD=bar
RUN mkdir -p ~/.bitcoin
RUN echo "rpcuser=${RPC_USER}\nrpcpassword=${RPC_PASSWORD}\n${NETWORK}=1\nrpcport=8332\nrpcallowip=127.0.0.1\nrpcconnect=127.0.0.1\n" > /root/.bitcoin/bitcoin.conf
ENTRYPOINT bitcoind -daemon
