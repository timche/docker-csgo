#!/bin/bash

set -e

if [ "${DEBUG}" = "true" ]; then
  set -x
fi

shopt -s extglob

steam_dir="${HOME}/Steam"
server_dir="${HOME}/server"
server_installed_lock_file="${server_dir}/installed.lock"
csgo_dir="${server_dir}/csgo"
csgo_custom_files_dir="${CSGO_CUSTOM_FILES_DIR-"/usr/csgo"}"

install() {
  echo '> Installing server ...'

  set -x

  $steam_dir/steamcmd.sh \
    +login anonymous \
    +force_install_dir $server_dir \
    +app_update 740 validate \
    +quit

  set +x

  echo '> Done'

  touch $server_installed_lock_file
}

sync_custom_files() {
  echo "> Checking for custom files at \"$csgo_custom_files_dir\" ..."

  if [ -d "$csgo_custom_files_dir" ]; then
    echo '> Found custom files, applying ...'

    set -x

    rsync -rti $csgo_custom_files_dir/ $csgo_dir

    set +x

    echo '> Done'
  else
    echo '> No custom files found'
  fi
}

should_add_server_configs() {
  if [ "${SERVER_CONFIGS-"false"}" = "true" ]; then
    cd $csgo_dir

    version="${SERVER_CONFIGS_VERSION-"0.3.0"}"
    server_configs_url="https://github.com/timche/csgo-server-configs/releases/download/v${version}/csgo-server-configs-${version}.zip"

    if [ ! -f "server_configs" ]; then
      touch "server_configs"
    fi

    installed=$(<server_configs)

    if [ "${installed}" != "${server_configs_url}" ]; then
      wget -q -O server_configs.zip $server_configs_url
      unzip -qo server_configs.zip
      rm server_configs.zip
      echo $server_configs_url >"server_configs"
    fi
  fi
}

should_disable_bots() {
  cd $csgo_dir

  if [ "${CSGO_DISABLE_BOTS-"false"}" = "true" ]; then
    if [ -f "botchatter.db" ]; then
      rm "botchatter.db"
    fi

    if [ -f "botprofilecoop.db" ]; then
      rm "botprofilecoop.db"
    fi

    if [ -f "botprofile.db" ]; then
      rm "botprofile.db"
    fi
  fi
}

start() {
  echo '> Starting server ...'

  additionalParams=""

  if [ -n "$CSGO_GSLT" ]; then
    additionalParams+=" +sv_setsteamaccount $CSGO_GSLT"
  else
    echo '> Warning: Environment variable "CSGO_GSLT" is not set, but is required to run the server on the internet. Running the server in LAN mode instead.'
    additionalParams+=" +sv_lan 1"
  fi

  if [ -n "$CSGO_PW" ]; then
    additionalParams+=" +sv_password $CSGO_PW"
  fi

  if [ -n "$CSGO_HOSTNAME" ]; then
    additionalParams+=" +hostname $CSGO_HOSTNAME"
    additionalParams+=
  fi

  if [ -n "$CSGO_WS_API_KEY" ]; then
    additionalParams+=" -authkey $CSGO_WS_API_KEY"
  fi

  if [ "${CSGO_FORCE_NETSETTINGS-"false"}" = "true" ]; then
    additionalParams+=" +sv_minrate 786432 +sv_mincmdrate 128 +sv_minupdaterate 128"
  fi

  if [ "${CSGO_TV_ENABLE-"false"}" = "true" ]; then
    additionalParams+=" +tv_enable 1"
    additionalParams+=" +tv_delaymapchange ${CSGO_TV_DELAYMAPCHANGE-1}"
    additionalParams+=" +tv_delay ${CSGO_TV_DELAY-45}"
    additionalParams+=" +tv_deltacache ${CSGO_TV_DELTACACHE-2}"
    additionalParams+=" +tv_dispatchmode ${CSGO_TV_DISPATCHMODE-1}"
    additionalParams+=" +tv_maxclients ${CSGO_TV_MAXCLIENTS-10}"
    additionalParams+=" +tv_maxrate ${CSGO_TV_MAXRATE-0}"
    additionalParams+=" +tv_overridemaster ${CSGO_TV_OVERRIDEMASTER-0}"
    additionalParams+=" +tv_snapshotrate ${CSGO_TV_SNAPSHOTRATE-128}"
    additionalParams+=" +tv_timeout ${CSGO_TV_TIMEOUT-60}"
    additionalParams+=" +tv_transmitall ${CSGO_TV_TRANSMITALL-1}"

    if [ -n "${CSGO_TV_NAME}" ]; then
      additionalParams+=" +tv_name ${CSGO_TV_NAME}"
    fi

    if [ -n "${CSGO_TV_PORT}" ]; then
      additionalParams+=" +tv_port ${CSGO_TV_PORT}"
    fi

    if [ -n "${CSGO_TV_PASSWORD}" ]; then
      additionalParams+=" +tv_password ${CSGO_TV_PASSWORD}"
    fi
  fi

  set -x

  exec $server_dir/srcds_run \
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
    +rcon_password "${CSGO_RCON_PW-changeme}" \
    $additionalParams \
    $CSGO_PARAMS
}

update() {
  echo '> Checking for server update ...'

  set -x

  $steam_dir/steamcmd.sh \
    +login anonymous \
    +force_install_dir $HOME/server \
    +app_update 740 \
    +quit

  set +x

  echo '> Done'
}

install_or_update() {
  if [ -f "$server_installed_lock_file" ]; then
    update
  else
    install
  fi
}

if [ ! -z $1 ]; then
  $1
else
  install_or_update
  should_add_server_configs
  should_disable_bots
  sync_custom_files
  start
fi
