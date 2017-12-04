FROM ubuntu:14.04

RUN apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure apt-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
	git build-essential gperf \
	bison flex texinfo wget \
	gawk libtool automake openssh-client \
	libncurses5-dev help2man rsync cmake \
	ca-certificates python unzip bc \
 	make gcc ncurses-dev bison flex gawk \
	gettext ccache zlib1g-dev libx11-dev texinfo liblzo2-dev pax-utils corkscrew \
	&&  apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

## add x32 features

RUN DEBIAN_FRONTEND=noninteractive dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386


RUN mkdir tools
WORKDIR tools
ENV TOOLS tools

#download toolchain for nios 2
#RUN wget https://sourcery.mentor.com/GNUToolchain/package15272/public/nios2-linux-gnu/sourceryg++-2017.11-10-nios2-linux-gnu-i686-pc-linux-gnu.tar.bz2
#RUN tar xvf sourceryg++-2017.11-10-nios2-linux-gnu-i686-pc-linux-gnu.tar.bz2 \
#	&& rm sourceryg++-2017.11-10-nios2-linux-gnu-i686-pc-linux-gnu.tar.bz2
RUN wget ftp://ftp.altera.com/outgoing/nios2gcc-20080203.tar.bz2 \
	&& tar xvf nios2gcc-20080203.tar.bz2 \
	&& rm nios2gcc-20080203.tar.bz2

ENV TOOLCHAIN_PATH=/${TOOLS}/opt/nios2 \
	ARCH=nios2nommu \
	CROOS_COMPILE=nios2-linux-uclibc-
ENV PATH=$TOOLCHAIN_PATH/bin:$PATH

RUN ${CROOS_COMPILE}gcc --version 
# download uclinux-dist
RUN wget http://www.uclinux.org/pub/uClinux/dist/uClinux-dist-20140504.tar.bz2 \
	&& tar xvf uClinux-dist-20140504.tar.bz2 \
	&& rm uClinux-dist-20140504.tar.bz2

COPY nios2_dfconfig /uClinux-dist/.config
RUN make


RUN mkdir /scripts
WORKDIR /scripts
ENV SCRIPTS /scripts

RUN mkdir /workspace
ENV WORKSPACE /workspace
WORKDIR /workspace
VOLUME ["/workspace"]

# RUN useradd -ms /bin/bash build
# USER build
# ENV HOME=/home/build
# WORKDIR ${HOME}

