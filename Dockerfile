ARG ARCH
FROM ${ARCH}/ubuntu:bionic
MAINTAINER yhaenggi <yhaenggi-git-public@darkgamex.ch>

ARG ARCH
ARG VERSION
ARG IMAGE
ENV VERSION=${VERSION}
ENV ARCH=${ARCH}
ENV IMAGE=${IMAGE}

COPY ./qemu-i386-static /usr/bin/qemu-i386-static
COPY ./qemu-x86_64-static /usr/bin/qemu-x86_64-static
COPY ./qemu-arm-static /usr/bin/qemu-arm-static
COPY ./qemu-aarch64-static /usr/bin/qemu-aarch64-static

RUN echo force-unsafe-io | tee /etc/dpkg/dpkg.cfg.d/docker-apt-speedup
RUN apt-get update

# set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive
#install tzdata package
RUN apt-get install tzdata -y
# set your timezone
RUN ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get install software-properties-common -y
RUN add-apt-repository universe
RUN add-apt-repository multiverse

RUN sed 's/# deb-src/deb-src/g' -i /etc/apt/sources.list
RUN apt-get update

RUN apt-get build-dep taskd -y
RUN apt-get install git debhelper fakeroot devscripts -y
RUN apt-get install build-essential -y

WORKDIR /tmp/
RUN git clone --depth 1 --branch ${VERSION} https://github.com/GothenburgBitFactory/taskserver ${IMAGE}
WORKDIR /tmp/${IMAGE}/

RUN cmake -DCMAKE_BUILD_TYPE=release .
RUN bash -c "nice -n 20 make -j$(nproc)"

RUN rm /usr/bin/qemu-x86_64-static /usr/bin/qemu-arm-static /usr/bin/qemu-aarch64-static /usr/bin/qemu-i386-static

FROM ${ARCH}/ubuntu:bionic
ARG IMAGE
ENV IMAGE=${IMAGE}

COPY ./qemu-i386-static /usr/bin/qemu-i386-static
COPY ./qemu-x86_64-static /usr/bin/qemu-x86_64-static
COPY ./qemu-arm-static /usr/bin/qemu-arm-static
COPY ./qemu-aarch64-static /usr/bin/qemu-aarch64-static

WORKDIR /root/

# set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

#install tzdata package
# dependencies. netcat used for probes
RUN apt-get update && apt-get install tzdata netcat libgnutlsxx28 uuid -y && apt-get clean && rm -Rf /var/cache/apt/ && rm -Rf /var/lib/apt/lists

# set your timezone
RUN ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN mkdir -p /home/taskserver/.taskserver
RUN useradd -M -d /home/taskserver -u 911 -U -s /bin/bash taskserver
RUN usermod -G users taskserver

COPY --from=0 /tmp/${IMAGE}/src/taskd /usr/bin/taskd

RUN chown taskserver:taskserver /home/taskserver -R

RUN rm /usr/bin/qemu-x86_64-static /usr/bin/qemu-arm-static /usr/bin/qemu-aarch64-static /usr/bin/qemu-i386-static

USER taskserver
WORKDIR /home/taskserver

EXPOSE 64738/tcp 64738/udp 50051

ENTRYPOINT ["/usr/bin/taskd"]
CMD ["server", "--data", "/home/taskserver/.taskserver"]
