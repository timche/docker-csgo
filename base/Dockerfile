FROM debian:buster-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates=20200601~deb10u2 \
    lib32gcc1=1:8.3.0-6 \
    lib32stdc++6=8.3.0-6 \
    lib32z1=1:1.2.11.dfsg-1+deb10u2 \
    rsync=3.1.3-6 \
    unzip=6.0-23+deb10u2 \
    wget=1.20.1-1.1 \
    locales \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m vietnam

USER vietnam

RUN mkdir /home/vietnam/Steam && \
    mkdir /home/vietnam/server

WORKDIR /home/vietnam/Steam

RUN wget -qO- https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxf - \
    && /home/vietnam/Steam/steamcmd.sh +quit \
    && mkdir -p /home/vietnam/.steam/sdk64 \
    && ln -s /home/vietnam/Steam/linux64/steamclient.so /home/vietnam/.steam/sdk64/steamclient.so

WORKDIR /home/vietnam

COPY server.sh .

CMD [ "/home/vietnam/server.sh" ]