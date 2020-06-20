#!/bin/bash

set -e

shopt -s extglob

server=$HOME/server.sh
server_sourcemod=$HOME/server_sourcemod.sh
csgo_dir=$HOME/server/csgo

practicemode_version="${PRACTICEMODE_VERSION-"1.3.3"}"
practicemode_url="https://github.com/splewis/csgo-practice-mode/releases/download/${practicemode_version}/practicemode_${practicemode_version}.zip"

pugsetup_version="${PUGSETUP_VERSION-"2.0.5"}"
pugsetup_url="https://github.com/splewis/csgo-pug-setup/releases/download/${pugsetup_version}/pugsetup_${pugsetup_version}.zip"

install_or_update_plugins() {
  $server_sourcemod install_or_update_plugin 'pugsetup' $pugsetup_url
  $server_sourcemod install_or_update_plugin 'practicemode' $practicemode_url
}

manage_plugins() {
  if [ "${PUG_PRACTICE_MINIMAL_PLUGINS-"false"}" = "true" ]; then
    enabledPlugins="admin-flatfile,botmimic,csutils,practicemode,pugsetup"

    if [ "${PUGSETUP_AUTOKICKER-"false"}" = "true" ]; then
      enabledPlugins+=",pugsetup_autokicker"
    fi

    if [ "${PUGSETUP_TEAMLOCKER-"false"}" = "true" ]; then
      enabledPlugins+=",pugsetup_teamlocker"
    fi

    if [ "${PUGSETUP_DAMAGEPRINT-"false"}" = "true" ]; then
      enabledPlugins+=",pugsetup_damageprint"
    fi

    if [ "${PUGSETUP_TEAMNAMES-"false"}" = "true" ]; then
      enabledPlugins+=",pugsetup_teamnames"
    fi

    if [ -n "${SOURCEMOD_PLUGINS_ENABLED}" ]; then
      enabledPlugins+=",${SOURCEMOD_PLUGINS_ENABLED}"
    fi

    SOURCEMOD_PLUGINS_DISABLED="*" SOURCEMOD_PLUGINS_ENABLED="${enabledPlugins}" $server_sourcemod manage_plugins
  else
    $server_sourcemod manage_plugins
  fi
}

if [ ! -z $1 ]; then 
  $1
else
  $server install_or_update
  $server_sourcemod install_or_update_mods
  install_or_update_plugins
  manage_plugins
  $server sync_custom_files
  $server start
fi