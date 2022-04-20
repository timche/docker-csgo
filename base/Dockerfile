FROM debian:buster-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates=20200601~deb10u2 \
    lib32gcc1=1:8.3.0-6 \
    lib32stdc++6=8.3.0-6 \
    rsync=3.1.3-6 \
    unzip=6.0-23+deb10u2 \
    wget=1.20.1-1.1 \
    lib32z1=1:1.2.11.dfsg-1 \
    locales=2.28-10 \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m csgo

USER csgo

RUN mkdir /home/csgo/Steam && \
    mkdir /home/csgo/server

WORKDIR /home/csgo/Steam

RUN wget -qO- https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxf - \
    && /home/csgo/Steam/steamcmd.sh +quit \
    && mkdir -p /home/csgo/.steam/sdk32 \
    && ln -s /home/csgo/Steam/linux32/steamclient.so /home/csgo/.steam/sdk32/steamclient.so

WORKDIR /home/csgo

COPY server.sh .

CMD [ "bash", "/home/csgo/server.sh" ]