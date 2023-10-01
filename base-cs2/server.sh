#!/bin/bash

set -e

shopt -s extglob

steam_dir="${HOME}/Steam"
server_dir="${HOME}/server"
server_installed_lock_file="${server_dir}/installed.lock"
cs2_dir="${server_dir}/game/csgo"
cs2_custom_files_dir="${CS2_CUSTOM_FILES_DIR-"/usr/csgo"}"


install() {
  echo '> Installing or updating game files ...'

  validate=""
  if [ "${VALIDATE_SERVER_FILES-"false"}" = "true" ]; then
    echo '> Validating game files ...'
    validate="validate"
  fi

  $steam_dir/steamcmd.sh \
    +force_install_dir $server_dir \
    +login "${STEAM_USERNAME}" "${STEAM_PASSWORD}" \
    +app_update 730 ${validate} \
    +quit

  echo '> Done'

  touch $server_installed_lock_file
}

sync_custom_files() {
  echo "> Checking for custom files at \"$cs2_custom_files_dir\" ..."

  if [ -d "$cs2_custom_files_dir" ]; then
    echo "> Found custom files. Syncing with \"${cs2_dir}\" ..."

    set -x

    cp -asf $cs2_custom_files_dir/* $cs2_dir  # Copy custom files as soft links
    find $cs2_dir -xtype l -delete            # Find and delete broken soft links

    set +x

    echo '> Done'
  else
    echo '> No custom files found'
  fi
}

start() {
  echo '> Starting server ...'

  additionalParams=""

  if [ -n "$CS2_PW" ]; then
    additionalParams+=" +sv_password $CS2_PW"
  fi

  set -x

  exec $server_dir/game/bin/linuxsteamrt64/cs2 \
    -dedicated \
    -console \
    -usercon \
    -maxplayers_override "${CS2_MAX_PLAYERS-16}" \
    +game_alias "${CS2_GAME_ALIAS-competetive}" \
    +mapgroup "${CS2_MAP_GROUP-mg_active}" \
    +map "${CS2_MAP-de_dust2}" \
    +rcon_password "${CS2_RCON_PW-changeme}" \
    $additionalParams \
    $CS2_PARAMS
}

if [ ! -z $1 ]; then
  $1
else
  install
  sync_custom_files
  start
fi

