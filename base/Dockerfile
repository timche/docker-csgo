FROM debian:buster-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates=20190110 \
    lib32gcc1=1:8.3.0-6 \
    lib32stdc++6=8.3.0-6 \
    rsync=3.1.3-6 \
    unzip=6.0-23+deb10u1 \
    wget=1.20.1-1.1 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m csgo

USER csgo

RUN mkdir /home/csgo/Steam

WORKDIR /home/csgo/Steam

RUN wget -qO- https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxf - \
    && /home/csgo/Steam/steamcmd.sh +quit

WORKDIR /home/csgo

RUN mkdir server

COPY server.sh .

CMD [ "/home/csgo/server.sh" ]