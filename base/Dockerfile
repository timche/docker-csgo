FROM debian:bullseye-slim

ARG PACKAGES="ca-certificates lib32gcc1 lib32stdc++6 rsync unzip wget lib32z1 locales"
ARG LOCALE="en_US.UTF-8 UTF-8"
ARG STEAMCMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"

RUN apt-get update \
    && apt-get install -y --no-install-recommends $PACKAGES

RUN echo $LOCALE | tee /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales

RUN rm -rf /var/lib/apt/lists/*
RUN useradd -m csgo

USER csgo

RUN mkdir /home/csgo/Steam && \
    mkdir /home/csgo/server

WORKDIR /home/csgo/Steam

RUN curl -SsL $STEAMCMD_URL | tar zxf - \
    && /home/csgo/Steam/steamcmd.sh +quit \
    && mkdir -p /home/csgo/.steam/sdk32 \
    && ln -s /home/csgo/Steam/linux32/steamclient.so /home/csgo/.steam/sdk32/steamclient.so

WORKDIR /home/csgo

COPY server.sh .

CMD [ "/home/csgo/server.sh" ]