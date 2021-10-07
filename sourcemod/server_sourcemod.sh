#!/bin/bash

set -e

if [ "${DEBUG}" = "true" ]; then
  set -x
fi

shopt -s extglob

args=("$@")

server=$HOME/server.sh
csgo_dir=$HOME/server/csgo
sourcemod_plugins_dir=$csgo_dir/addons/sourcemod/plugins

mmsource_exact_version="${METAMOD_VERSION-"1.11.0"}"
mmsource_version=$(echo ${mmsource_exact_version} | cut -f1-2 -d '.')
mmsource_url="https://mms.alliedmods.net/mmsdrop/${mmsource_version}/mmsource-${mmsource_exact_version}-git${METAMOD_BUILD-1145}-linux.tar.gz"

sourcemod_exact_version="${SOURCEMOD_VERSION-"1.10.0"}"
sourcemod_version=$(echo ${sourcemod_exact_version} | cut -f1-2 -d '.')
sourcemod_url="https://sm.alliedmods.net/smdrop/${sourcemod_version}/sourcemod-${sourcemod_exact_version}-git${SOURCEMOD_BUILD-6516}-linux.tar.gz"

install_or_update_mod() {
  cd $csgo_dir

  if [ ! -f "$1" ]; then
    touch $1
  fi

  installed=$(<$1)

  if [ "${installed}" = "$2" ]; then
    return
  fi

  if [ -z "${installed}" ]; then
    echo "> Installing mod ${1} from ${2} ..."
  else
    echo "> Updating mod ${1} from ${2} ..."
  fi

  wget -qO- $2 | tar zxf -

  echo $2 > $1

  echo '> Done'
}

install_or_update_mods() {
  install_or_update_mod 'mmsource' $mmsource_url
  install_or_update_mod 'sourcemod' $sourcemod_url
}

install_or_update_plugin() {
  cd $csgo_dir

  if [ ! -f "${args[1]}" ]; then
    touch ${args[1]}
  fi

  installed=$(<${args[1]})

  if [ "${installed}" = "${args[2]}" ]; then
    return
  fi

  if [ -z "${installed}" ]; then
    echo "> Installing SourceMod plugin ${args[1]} from ${args[2]} ..."
  else
    echo "> Updating SourceMod plugin ${args[1]} from ${args[2]} ..."
  fi

  wget -q -O plugin.zip ${args[2]}

  if [ -z "${installed}" ]; then
    unzip -qn plugin.zip
  else
    unzip -qo plugin.zip
  fi

  rm plugin.zip

  echo ${args[2]} > ${args[1]}

  echo '> Done'
}

manage_plugins() {
  echo '> Managing SourceMod plugins ...'

  cd $sourcemod_plugins_dir

  if [ "${SOURCEMOD_PLUGINS_DISABLED}" = "*" ]; then
    for plugin in *.smx; do
      if [ -f "${plugin}" ]; then
        echo "> Disabling ${plugin}"
        mv $plugin disabled
      fi
    done
  elif [ -n "${SOURCEMOD_PLUGINS_DISABLED}" ]; then
    for plugin in $(echo $SOURCEMOD_PLUGINS_DISABLED | sed "s/,/ /g"); do
      if [ -f "${plugin}.smx" ]; then
        echo "> Disabling ${plugin}.smx"
        mv "${plugin}.smx" disabled
      fi
    done
  fi

  cd disabled

  if [ "${SOURCEMOD_PLUGINS_ENABLED}" = "*" ]; then
    for plugin in *.smx; do
      if [ -f "${plugin}" ]; then
        echo "> Enabling ${plugin}"
        mv $plugin ..
      fi
    done
  elif [ -n "${SOURCEMOD_PLUGINS_ENABLED}" ]; then
    for plugin in $(echo $SOURCEMOD_PLUGINS_ENABLED | sed "s/,/ /g"); do
      if [ -f "${plugin}.smx" ]; then
        echo "> Enabling ${plugin}.smx"
        mv "${plugin}.smx" ..
      fi
    done
  fi

  echo '> Done'
}

manage_admins() {
  if [ -n "${SOURCEMOD_ADMINS}" ]; then
    admins_simple="${csgo_dir}/addons/sourcemod/configs/admins_simple.ini"

    if [ -f "${admins_simple}" ]; then
      > $admins_simple

      for steamid in $(echo $SOURCEMOD_ADMINS | sed "s/,/ /g"); do
        echo "\"$steamid\" \"z\"" >> $admins_simple
      done
    fi
  fi
}

if [ ! -z $1 ]; then
  $1
else
  $server install_or_update
  install_or_update_mods
  manage_plugins
  manage_admins
  $server should_add_server_configs
  $server should_disable_bots
  $server sync_custom_files
  exec $server start
fi
