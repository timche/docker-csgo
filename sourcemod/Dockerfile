FROM timche/csgo

USER root

RUN apt-get install lib32z1=1:1.2.11.dfsg-1

USER csgo

WORKDIR /home/csgo

COPY server_sourcemod.sh .

CMD [ "/home/csgo/server_sourcemod.sh" ]