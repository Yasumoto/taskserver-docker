FROM ubuntu:focal
MAINTAINER Joe Smith <yasumoto7@gmail.com>

ARG VERSION
ENV VERSION=${VERSION}

RUN apt-get update

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install tzdata -y
RUN ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

#RUN apt-get install software-properties-common -y
#RUN add-apt-repository universe
#RUN add-apt-repository multiverse

#RUN sed 's/# deb-src/deb-src/g' -i /etc/apt/sources.list
#RUN apt-get update

RUN apt-get install git debhelper fakeroot devscripts \
    g++ libgnutls28-dev uuid-dev cmake gnutls-bin \
    build-essential tzdata netcat libgnutlsxx28 uuid -y && \
    apt-get clean && rm -Rf /var/cache/apt/ && rm -Rf /var/lib/apt/lists

WORKDIR /tmp/
RUN git clone --depth 1 --branch ${VERSION} https://github.com/GothenburgBitFactory/taskserver taskserver
WORKDIR /tmp/taskserver/

RUN cmake -DCMAKE_BUILD_TYPE=release .
RUN bash -c "nice -n 20 make -j$(nproc)"

WORKDIR /root/

RUN mkdir -p /home/taskserver/.taskserver
RUN useradd -M -d /home/taskserver -u 911 -U -s /bin/bash taskserver
RUN usermod -G users taskserver

RUN cp /tmp/taskserver/src/taskd /usr/bin/taskd

RUN chown taskserver:taskserver /home/taskserver -R

USER taskserver
WORKDIR /home/taskserver

EXPOSE 64738/tcp 64738/udp 50051

ENTRYPOINT ["/usr/bin/taskd"]
CMD ["server", "--data", "/home/taskserver/.taskserver"]
