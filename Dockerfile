FROM debian:jessie-backports

ARG UID=1000
ARG GID=1000

ENV Q_INST_DIR=/opt/intelFPGA_lite/20.1

ENV QUARTUS_ROOTDIR=${Q_INST_DIR}/quartus
ENV SOPC_KIT_NIOS2=${Q_INST_DIR}/nios2eds

ENV PATH=${Q_INST_DIR}/quartus/sopc_builder/bin/:$PATH
ENV PATH=${Q_INST_DIR}/quartus/bin/:$PATH
ENV PATH=${Q_INST_DIR}/nios2eds/:$PATH
ENV PATH=${Q_INST_DIR}/nios2eds/bin/:$PATH
ENV PATH=${Q_INST_DIR}/nios2eds/sdk2/bin/:$PATH
ENV PATH=${Q_INST_DIR}/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/bin/:$PATH
ENV PATH=${Q_INST_DIR}/quartus/linux64/gnu/:$PATH


# basic packages
RUN echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list && \
    echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/backports.list && \
    sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list && \
    echo "Acquire::Check-Valid-Until \"false\";" > /etc/apt/apt.conf.d/100disablechecks && \
    apt-get update && apt-get -y install expect locales wget libtcmalloc-minimal4 libglib2.0-0 default-jre && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8

# adding scripts
ADD files/ /

# install quartus prime
# 19.1.0 http://download.altera.com/akdlm/software/acdsinst/19.1std/670/ib_tar/Quartus-lite-19.1.0.670-linux.tar
RUN mkdir -p /root/quartus && \
    cd /root/quartus && \
    wget -q http://download.altera.com/akdlm/software/acdsinst/20.1std/711/ib_tar/Quartus-lite-20.1.0.711-linux.tar && \
    tar xvf Quartus-lite-20.1.0.711-linux.tar && \
    /root/setup 20.1 && rm -rf /root/quartus && rm -rf /root/setup*

RUN useradd -u ${UID} -m -s /bin/bash quartus
ENV LD_LIBRARY_PATH=/opt/intelFPGA_lite/20.1/quartus/linux64/
ENV LD_PRELOAD=/usr/lib/libtcmalloc_minimal.so.4
ENV LC_ALL="en_US.UTF-8"
USER quartus
WORKDIR /home/quartus
