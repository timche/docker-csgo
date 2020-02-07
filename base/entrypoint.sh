#!/bin/bash

set -e

set -x

shopt -s extglob

STEAM_DIR=$HOME/Steam
SERVER_DIR=$HOME/server
SERVER_INSTALLED_LOCK_FILE=$SERVER_DIR/installed.lock
CSGO_DIR=$SERVER_DIR/csgo
CSGO_CUSTOM_CONFIGS_DIR="${CSGO_CUSTOM_CONFIGS_DIR-/var/csgo}"

installServer() {
  echo '> Installing server ...'

  $STEAM_DIR/steamcmd.sh \
    +login anonymous \
    +force_install_dir $SERVER_DIR \
    +app_update 740 validate \
    +quit

  echo '> Done'

  touch $SERVER_INSTALLED_LOCK_FILE

}

applyCustomConfigs() {
  echo "> Checking for custom configs at \"$CSGO_CUSTOM_CONFIGS_DIR\" ..."

  if [ -d "$CSGO_CUSTOM_CONFIGS_DIR" ]; then
      echo '> Found custom configs, applying ...'
      rsync -ri $CSGO_CUSTOM_CONFIGS_DIR/ $CSGO_DIR
      echo '> Done'
  else
      echo '> No custom configs found to apply'
  fi
}

startServer() {
  echo '> Starting server ...'

  optionalParameters=""

  if [ -n "$CSGO_GSLT" ]; then
    optionalParameters+=" +sv_setsteamaccount $CSGO_GSLT"
  else
    echo '> Warning: Environment variable "CSGO_GSLT" is not set, but is required to run the server on the internet. Running the server in LAN mode.'
    optionalParameters+=" +sv_lan 1"
  fi

  if [ -n "$CSGO_RCON_PW" ]; then
    optionalParameters+=" +rcon_password $CSGO_RCON_PW"
  fi

  if [ -n "$CSGO_PW" ]; then
    optionalParameters+=" +sv_password $CSGO_PW"
  fi

  if [ -n "$CSGO_HOSTNAME" ]; then
    optionalParameters+=" +hostname $CSGO_HOSTNAME"
  fi

  if [ -n "$CSGO_WS_API_KEY" ]; then
    optionalParameters+=" -authkey $CSGO_WS_API_KEY"
  fi

  $SERVER_DIR/srcds_run \
      -game csgo \
      -console \
      -norestart \
      -usercon \
      -nobreakpad \
      +ip "${CSGO_IP-0.0.0.0}" \
      -port "${CSGO_PORT-27015}" \
      -tickrate "${CSGO_TICKRATE-128}" \
      -maxplayers_override "${CSGO_MAX_PLAYERS-16}" \
      +game_type "${CSGO_GAME_TYPE-0}" \
      +game_mode "${CSGO_GAME_MODE-1}" \
      +mapgroup "${CSGO_MAP_GROUP-mg_active}" \
      +map "${CSGO_MAP-de_dust2}" \
      $optionalParameters \
      $CSGO_PARAMS
}

updateServer() {
  echo '> Checking for server update ...'

  $STEAM_DIR/steamcmd.sh \
    +login anonymous \
    +force_install_dir $HOME/server \
    +app_update 740 \
    +quit

  echo '> Done'
}

if [ -f "$SERVER_INSTALLED_LOCK_FILE" ]; then
  updateServer
else
  installServer
fi

applyCustomConfigs

startServer