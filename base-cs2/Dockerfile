FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    rsync \
    unzip \
    wget \
    lib32z1 \
    locales \
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
    && mkdir -p /home/csgo/.steam/sdk64 \
    && ln -s /home/csgo/Steam/linux64/steamclient.so /home/csgo/.steam/sdk64/steamclient.so

WORKDIR /home/csgo

COPY server.sh .

ENTRYPOINT ["/home/csgo/server.sh"]

