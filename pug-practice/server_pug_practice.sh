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

    if [ -n "${SOURCEMOD_PLUGINS_ENABLED}" ]; then
      enabledPlugins+=",${SOURCEMOD_PLUGINS_ENABLED}"
    fi

    SOURCEMOD_PLUGINS_DISABLED="*" SOURCEMOD_PLUGINS_ENABLED="${enabledPlugins}" $server_sourcemod manage_plugins
  else
    $server_sourcemod manage_plugins
  fi
}

set_cvars() {
  if [ -n "${PUGSETUP_CVARS}" ]; then
    pugsetup_cfg="${csgo_dir}/cfg/sourcemod/pugsetup/pugsetup.cfg"

    if [ -f "${pugsetup_cfg}" ]; then
      for cvar_value in $(echo $PUGSETUP_CVARS | sed "s/,/ /g"); do
        cvar=$(echo $cvar_value | cut -f1 -d=)
        value=$(echo $cvar_value | cut -f2 -d=)

        sed -i "s/${cvar} \"[^\]*\"/${cvar} \"${value}\"/g" $pugsetup_cfg
      done
    fi
  fi
}

if [ ! -z $1 ]; then 
  $1
else
  $server install_or_update
  $server_sourcemod install_or_update_mods
  install_or_update_plugins
  manage_plugins
  $server_sourcemod manage_admins
  $server should_add_server_configs
  $server should_disable_bots
  set_cvars
  $server sync_custom_files
  $server start
fi