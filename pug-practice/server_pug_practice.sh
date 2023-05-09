#!/bin/bash

set -e

if [ "${DEBUG}" = "true" ]; then
  set -x
fi

shopt -s extglob

server=$HOME/server.sh
server_sourcemod=$HOME/server_sourcemod.sh
csgo_dir=$HOME/server/csgo

practicemode_version="${PRACTICEMODE_VERSION-"1.3.4"}"
practicemode_url="https://github.com/splewis/csgo-practice-mode/releases/download/${practicemode_version}/practicemode_${practicemode_version}.zip"

pugsetup_version="${PUGSETUP_VERSION-"2.0.7"}"
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

set_pugsetup_permissions() {
  if [ -n "${PUGSETUP_PERMISSIONS}" ]; then
    pugsetup_permissions_cfg="${csgo_dir}/addons/sourcemod/configs/pugsetup/permissions.cfg"

    if [ -f "${pugsetup_permissions_cfg}" ]; then
      for permission_value in $(echo $PUGSETUP_PERMISSIONS | sed "s/,/ /g"); do
        permission=$(echo $permission_value | cut -f1 -d=)
        value=$(echo $permission_value | cut -f2 -d=)

        sed -i "s/\(\"${permission}\"\).*/\1 \"${value}\"/g" $pugsetup_permissions_cfg
      done
    fi
  fi
}

set_pugsetup_setupoptions() {
  if [ -n "${PUGSETUP_SETUPOPTIONS}" ]; then
    pugsetup_setupoptions_cfg="${csgo_dir}/addons/sourcemod/configs/pugsetup/setupoptions.cfg"

    if [ -f "${pugsetup_setupoptions_cfg}" ]; then
      for setting in $(echo $PUGSETUP_SETUPOPTIONS | sed "s/,/ /g"); do
        option=$(echo $setting | cut -f1 -d=)
        values=$(echo $setting | cut -f2 -d=)

        default_value=$(echo $values | awk -F: '{print $1}')

        if [ ! -z "${default_value}" ]; then
          sed -i "/${option}/!b;n;n;c\"default\" \"${default_value}\"" $pugsetup_setupoptions_cfg
        fi

        display_setting=$(echo $values | awk -F: '{print $2}')

        if [ ! -z "${display_setting}" ]; then
          sed -i "/${option}/!b;n;n;n;c\"display_setting\" \"${display_setting}\"" $pugsetup_setupoptions_cfg
        fi
      done
    fi
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

set_damageprint_cvars() {
  if [ -n "${PUGSETUP_DAMAGEPRINT_CVARS}" ]; then
    pugsetup_damageprint_cfg="${csgo_dir}/cfg/sourcemod/pugsetup/pugsetup_damageprint.cfg"

    if [ -f "${pugsetup_damageprint_cfg}" ]; then
      IFS=, read -ra cvar_values <<< "$PUGSETUP_DAMAGEPRINT_CVARS"
      for cvar_value in "${cvar_values[@]}"; do
        cvar=$(echo $cvar_value | cut -f1 -d=)
        value=$(echo $cvar_value | cut -f2 -d= | sed "s,/,\\\/,g")

        sed -i "s/${cvar} \"[^\]*\"/${cvar} \"${value}\"/g" $pugsetup_damageprint_cfg
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
  set_pugsetup_permissions
  set_pugsetup_setupoptions
  set_cvars
  set_damageprint_cvars
  $server sync_custom_files
  exec $server start
fi
