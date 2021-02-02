FROM timche/csgo

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    lib32z1=1:1.2.11.dfsg-1 \
    && rm -rf /var/lib/apt/lists/*

USER csgo

WORKDIR /home/csgo

COPY server_sourcemod.sh .

CMD [ "/home/csgo/server_sourcemod.sh" ]
