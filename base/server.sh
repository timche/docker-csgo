#!/bin/bash

set -e

if [ "${DEBUG}" = "true" ]; then
  set -x
fi

shopt -s extglob

steam_dir="${HOME}/Steam"
server_dir="${HOME}/server"
server_installed_lock_file="${server_dir}/installed.lock"
vietnam_dir="${server_dir}/vietnam"
vietnam_custom_files_dir="${VIETNAM_CUSTOM_FILES_DIR-"/usr/vietnam"}"

install() {
  echo '> Installing server ...'

  set -x

  $steam_dir/steamcmd.sh \
    +force_install_dir $server_dir \
    +login anonymous \
    +app_update 1136190 validate \
    +quit

  set +x

  echo '> Done'

  touch $server_installed_lock_file
}

sync_custom_files() {
  echo "> Checking for custom files at \"$vietnam_custom_files_dir\" ..."

  if [ -d "$vietnam_custom_files_dir" ]; then
    echo "> Found custom files. Syncing with \"${vietnam_dir}\" ..."

    set -x

    cp -asf $vietnam_custom_files_dir/* $vietnam_dir # Copy custom files as soft links
    find $vietnam_dir -xtype l -delete            # Find and delete broken soft links

    set +x

    echo '> Done'
  else
    echo '> No custom files found'
  fi
}

start() {
  echo '> Starting server ...'

  additionalParams=""

  additionalParams+=" +sv_lan 0"

  if [ -n "$VIETNAM_PW" ]; then
    additionalParams+=" +sv_password $VIETNAM_PW"
  fi

  if [ -n "$VIETNAM_HOSTNAME" ]; then
    additionalParams+=" +hostname $VIETNAM_HOSTNAME"
    additionalParams+=
  fi

  if [ -n "$VIETNAM_WS_API_KEY" ]; then
    additionalParams+=" -authkey $VIETNAM_WS_API_KEY"
  fi

  if [ "${VIETNAM_FORCE_NETSETTINGS-"false"}" = "true" ]; then
    additionalParams+=" +sv_minrate 786432 +sv_mincmdrate 128 +sv_minupdaterate 128"
  fi

  if [ "${VIETNAM_TV_ENABLE-"false"}" = "true" ]; then
    additionalParams+=" +tv_enable 1"
    additionalParams+=" +tv_delaymapchange ${VIETNAM_TV_DELAYMAPCHANGE-1}"
    additionalParams+=" +tv_delay ${VIETNAM_TV_DELAY-45}"
    additionalParams+=" +tv_deltacache ${VIETNAM_TV_DELTACACHE-2}"
    additionalParams+=" +tv_dispatchmode ${VIETNAM_TV_DISPATCHMODE-1}"
    additionalParams+=" +tv_maxclients ${VIETNAM_TV_MAXCLIENTS-10}"
    additionalParams+=" +tv_maxrate ${VIETNAM_TV_MAXRATE-0}"
    additionalParams+=" +tv_overridemaster ${VIETNAM_TV_OVERRIDEMASTER-0}"
    additionalParams+=" +tv_snapshotrate ${VIETNAM_TV_SNAPSHOTRATE-128}"
    additionalParams+=" +tv_timeout ${VIETNAM_TV_TIMEOUT-60}"
    additionalParams+=" +tv_transmitall ${VIETNAM_TV_TRANSMITALL-1}"

    if [ -n "${VIETNAM_TV_NAME}" ]; then
      additionalParams+=" +tv_name ${VIETNAM_TV_NAME}"
    fi

    if [ -n "${VIETNAM_TV_PORT}" ]; then
      additionalParams+=" +tv_port ${VIETNAM_TV_PORT}"
    fi

    if [ -n "${VIETNAM_TV_PASSWORD}" ]; then
      additionalParams+=" +tv_password ${VIETNAM_TV_PASSWORD}"
    fi
  fi

  set -x

  exec $server_dir/srcds_run \
    -game vietnam \
    -console \
    -norestart \
    -usercon \
    -nobreakpad \
    +ip "${VIETNAM_IP-0.0.0.0}" \
    -port "${VIETNAM_PORT-27015}" \
    -tickrate "${VIETNAM_TICKRATE-64}" \
    -maxplayers_override "${VIETNAM_MAX_PLAYERS-16}" \
    +game_type "${VIETNAM_GAME_TYPE-0}" \
    +game_mode "${VIETNAM_GAME_MODE-1}" \
    +mapgroup "${VIETNAM_MAP_GROUP-1}" \
    +map "${VIETNAM_MAP-mcv_port}" \
    +rcon_password "${VIETNAM_RCON_PW-changeme}" \
    $additionalParams \
    $VIETNAM_PARAMS
}

update() {
  if [ "${VALIDATE_SERVER_FILES-"false"}" = "true" ]; then
    echo '> Validating server files and checking for server update ...'
  else
    echo '> Checking for server update ...'
  fi

  if [ "${VALIDATE_SERVER_FILES-"false"}" = "true" ]; then
    set -x

    $steam_dir/steamcmd.sh \
      +force_install_dir $server_dir \
      +login anonymous \
      +app_update 1136190 validate \
      +quit

    set +x
  else
    set -x

    $steam_dir/steamcmd.sh \
      +force_install_dir $server_dir \
      +login anonymous \
      +app_update 1136190 \
      +quit

    set +x
  fi

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
  sync_custom_files
  start
fi
