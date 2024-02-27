# docker-vietnam

> **⚠️ BASED ON THE GREAT WORK OF**
> [timche/docker-csgo](https://github.com/timche/docker-csgo)

<p>
  <a href="https://github.com/timche/docker-csgo-updater">
    <img alt="GitHub CI" src="https://github.com/timche/docker-csgo-updater/workflows/ci/badge.svg" />
  </a>
  <a href="https://hub.docker.com/r/timche/csgo">
    <img alt="Docker Image Version" src="https://img.shields.io/docker/v/timche/csgo/latest">
  </a>
  <a href="https://hub.docker.com/r/timche/csgo">
    <img alt="Docker Image Size" src="https://img.shields.io/docker/image-size/timche/csgo/latest">
  </a>
  <a href="https://hub.docker.com/r/timche/csgo">
    <img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/timche/csgo" />
  </a>
  <a href="https://hub.docker.com/r/timche/csgo">
    <img alt="Docker Stars" src="https://img.shields.io/docker/stars/timche/csgo" />
  </a>
</p>

> [Military Conflict: Vietnam](https://store.steampowered.com/app/1012110/Military_Conflict_Vietnam/) with automated/manual updating.


## Table of Contents

- [How to Use This Image](#how-to-use-this-image)
- [Image Variants](#image-variants)
- [Environment Variables](#environment-variables)
  - [General](#general)
  - [Mods](#mods)
  - [PugSetup/PracticeMode](#pugsetuppracticemode)
  - [Other](#other)
- [Managing SourceMod Plugins](#managing-sourcemod-plugins)
- [Populating with Own Server Files](#populating-with-own-server-files)
- [Updating the Server](#updating-the-server)
  - [Automated (recommended)](#automated-recommended)
  - [Manually](#manually)

## How to Use This Image

```sh
$ docker run \
  -v=csgo:/home/csgo/server \
  --net=host \
  timche/csgo
```

This is a bare minimum example and the server will be:

- installed on a volume named `csgo` to [ensure persistence of server files](https://docs.docker.com/storage/).
- running on the default port `27015` on the `host` network for [optimal network performance](https://docs.docker.com/network/host/)
- running in LAN mode since a [Game Server Login Token](#csgo_gslt) (GSLT) is required to run the server on the internet.

To configure the server with more advanced settings, set [environment variables](#environment-variables).

## Image Variants

Each variant refers to a tag, e.g. `timche/csgo:<tag>`.

##### [`latest`](https://github.com/timche/docker-csgo/blob/master/base/Dockerfile) / [`<version>`](https://github.com/timche/docker-csgo/blob/master/base/Dockerfile)

Vanilla CS:GO server.

##### [`sourcemod`](https://github.com/timche/docker-csgo/blob/master/sourcemod/Dockerfile) / [`<version>-sourcemod`](https://github.com/timche/docker-csgo/blob/master/sourcemod/Dockerfile)

Vanilla CS:GO server with untouched [Metamod:Source](https://www.sourcemm.net) and [SourceMod](https://www.sourcemod.net/).

##### [`pug-practice`](https://github.com/timche/docker-csgo/blob/master/pug-practice/Dockerfile) / [`<version>-pug-practice`](https://github.com/timche/docker-csgo/blob/master/pug-practice/Dockerfile)

Vanilla CS:GO server with untouched [Metamod:Source](https://www.sourcemm.net), [SourceMod](https://www.sourcemod.net/), [PugSetup](https://github.com/splewis/csgo-pug-setup) and [PracticeMode](https://github.com/splewis/csgo-practice-mode) (by [splewis](https://github.com/splewis)).

## Environment Variables

### General

##### `CSGO_GSLT`

Default: None

Your Game Server Login Token (GSLT) if you want to run the server on the internet.

- [Get GSLT](https://steamcommunity.com/dev/managegameservers)
- [What is GSLT?](https://docs.linuxgsm.com/steamcmd/gslt#what-is-gslt)
- [FAQ](https://docs.linuxgsm.com/steamcmd/gslt#faq)

Sets `+sv_setsteamaccount` in `srcds_run` parameters.

##### `CSGO_WS_API_KEY`

Default: None

Your [Steam Web API Key](https://steamcommunity.com/dev/apikey) to download workshop maps.

Sets `-authkey` in `srcds_run` parameters.

##### `CSGO_IP`

Default: `0.0.0.0`

Internet IP the server is accessible from. In most cases the default value is sufficient, but if you want to run a [GOTV server](https://developer.valvesoftware.com/wiki/SourceTV) or have issues connecting to the server, setting the IP can help.

Sets `+ip` in `srcds_run` parameters.

##### `CSGO_PORT`

Default: `27015`

Port the server is listening to.

Sets `-port` in `srcds_run` parameters.

##### `CSGO_MAP`

Default: `de_dust2`

Start the server with a specific map.

Sets `+map` in `srcds_run` parameters.

##### `CSGO_MAX_PLAYERS`

Default: `16`

Maximum players allowed to join the server.

Sets `-maxplayers_override` in `srcds_run` parameters.

##### `CSGO_HOSTNAME`

Default: `Counter-Strike: Global Offensive`

The server name. [It can't contain spaces](https://developer.valvesoftware.com/wiki/Command_Line_Options#Some_useful_console_variables_2), so if you need a server name with spaces, set `hostname` in a config instead, e.g. `server.cfg`.

Sets `+hostname` in `srcds_run` parameters.

##### `CSGO_RCON_PW`

Default: `changeme`

RCON password to administrate the server.

Sets `+rcon_password` in `srcds_run` parameters.

##### `CSGO_PW`

Default: None

Password to join the server.

Sets `+sv_password` in `srcds_run` parameters.

##### `CSGO_TICKRATE`

Default: `128`

Server tick rate which can be `64` or `128`. The default value gives the best game experience, but also requires most server hardware resources.

Sets `-tickrate` in `srcds_run` parameters.

##### `CSGO_GAME_TYPE`

Default: `0` (Competitive)

[Game type](https://developer.valvesoftware.com/wiki/CSGO_Game_Mode_Commands).

Sets `+game_type` in `srcds_run` parameters.

##### `CSGO_GAME_MODE`

Default: `1`

[Game mode](https://developer.valvesoftware.com/wiki/CSGO_Game_Mode_Commands).

Sets `+game_mode` in `srcds_run` parameters.

##### `CSGO_MAP_GROUP`

Default: `mg_active`

Map group.

Sets `+mapgroup` in `srcds_run` parameters.

##### `CSGO_TV_ENABLE`

Default: `false`

Enable GOTV. Can be enabled with `true`.

##### `CSGO_TV_NAME`

Default: `GOTV`

Set GOTV name.

##### `CSGO_TV_PASSWORD`

Default: None

Set GOTV password.

##### `CSGO_TV_DELAY`

Default: `45`

Set GOTV broadcast delay in seconds.

##### `CSGO_TV_PORT`

Default: `27020`

Set GOTV port.

##### `CSGO_TV_DELAYMAPCHANGE`

Default: `1`

Delay the map change on game server until rest of buffered game has been broadcasted.

##### `CSGO_TV_DELTACACHE`

Default: `2`

##### `CSGO_TV_DISPATCHMODE`

Default: `1`

##### `CSGO_TV_MAXCLIENTS`

Default: `10`

Maximum client number for GOTV.

##### `CSGO_TV_MAXRATE`

Default: `0`

Maximum bandwidth spend per client in bytes/second.

##### `CSGO_TV_OVERRIDEMASTER`

Default: `0`

##### `CSGO_TV_SNAPSHOTRATE`

Default: `128`

World snapshots broadcasted per second by GOTV.

##### `CSGO_TV_TIMEOUT`

Default: `60`

##### `CSGO_TV_TRANSMITALL`

Default: `1`

By default entities and events outside of the auto-director view are removed from GOTV broadcasts to save bandwidth. If `tv_transmitall` is enabled, the whole game is transmitted and spectators can switch their view to any player they want. This option increases bandwidth requirement per spectator client by factor 2 to 3.

##### `CSGO_FORCE_NETSETTINGS`

Default: `false`

Force client netsettings to highest `rate` (`786432`), `cmdrate` (`128`) and `updaterate` (`128`). This ensures optimal gameplay experience. Requires 128 [tick rate](#csgo_tickrate).

Sets `+sv_minrate`, `+sv_mincmdrate` and `+sv_minupdaterate` in `srcds` parameters.

##### `CSGO_PARAMS`

Additional `srcds_run` [parameters](https://developer.valvesoftware.com/wiki/Command_Line_Options#Command-line_parameters).

##### `CSGO_DISABLE_BOTS`

Default: `false`

Disable bots completely. Can be enabled with `true`.

This is not setting `bot_quota` to `0`, because it's buggy and still spawns bots when players are for example disconnecting or switching sides. This is also not setting `-nobots` parameter, because it's also buggy and causes radar bugs with smokes. This simply removes bot profile files, so the server can't spawn any bots as it can't find an appropriate difficulty profile. It just works™. Bots in PracticeMode still work though.

##### `CSGO_CUSTOM_FILES_DIR`

Default: `/usr/csgo`

Absolute path to a directory in the container containing custom server files. Changing this is not recommended in order to follow the documentation. See more at "[Populating with Own Server Files](#populating-with-own-server-files)".

##### `SERVER_CONFIGS`

Default: `false`

Add server configs for competitive 5v5, knife round, aim map and FFA deathmatch from [csgo-server-configs](https://github.com/timche/csgo-server-configs). Can be enabled with `true`.

##### `SERVER_CONFIGS_VERSION`

Default: `1.1.0`

[csgo-server-configs version](https://github.com/timche/csgo-server-configs/releases). Changing this will update/downgrade it on container start. Only works with `SERVER_CONFIGS` set to `true`.

### Mods

##### `METAMOD_VERSION`

> _`sourcemod`, `pug-practice` image only._

Default: `1.11.0`

[Metamod:Source version](https://www.sourcemm.net/downloads.php?branch=stable) running on the server. Changing this will update/downgrade it on container start.

##### `METAMOD_BUILD`

> _`sourcemod`, `pug-practice` image only._

Default: `1153`

[Metamod:Source build number](https://www.sourcemm.net/downloads.php?branch=stable) running on the server. Changing this will update/downgrade it on container start. Build number must exist at version.

##### `SOURCEMOD_VERSION`

> _`sourcemod`, `pug-practice` image only._

Default: `1.11.0`

[SourceMod version](https://www.sourcemod.net/downloads.php?branch=stable) running on the server. Changing this will update/downgrade it on container start.

##### `SOURCEMOD_BUILD`

> _`sourcemod`, `pug-practice` image only._

Default: `6954`

[SourceMod build number](https://www.sourcemod.net/downloads.php?branch=stable) running on the server. Changing this will update/downgrade it on container start. Build number must exist at version.

##### `SOURCEMOD_PLUGINS_DISABLED`

> _`sourcemod`, `pug-practice` image only._

Default: None

List of comma-separated SourceMod plugins (e.g. `nextmap,reservedslots,sounds`) that are disabled. `*` disables all plugins. The plugins are moved into the `disabled` folder on container start. This is running before `SOURCEMOD_PLUGINS_ENABLED`.

##### `SOURCEMOD_PLUGINS_ENABLED`

> _`sourcemod`, `pug-practice` image only._

Default: None

List of comma-separated SourceMod plugins (e.g. `mapchooser,randomcycle,rockthevote`) that are enabled. `*` enables all plugins. The plugins are moved out of the `disabled` folder into `plugins` on container start. This is running after `SOURCEMOD_PLUGINS_DISABLED`.

##### `SOURCEMOD_ADMINS`

> _`sourcemod`, `pug-practice` image only._

List of comma-separated Steam IDs that are SourceMod admins (e.g. `STEAM_0:0:123,STEAM_0:1:234`) with [`z` flag](<https://wiki.alliedmods.net/Adding_Admins_(SourceMod)>).

### PugSetup/PracticeMode

##### `PUGSETUP_VERSION`

> _`pug-practice` image only._

Default: `2.0.7`

[PugSetup version](https://github.com/splewis/csgo-pug-setup/releases) running on the server. Changing this will update/downgrade it on container start.

##### `PRACTICEMODE_VERSION`

> _`pug-practice` image only._

Default: `1.3.4`

[PracticeMode version](https://github.com/splewis/csgo-practice-mode/releases) running on the server. Changing this will update/downgrade it on container start.

##### `PUG_PRACTICE_MINIMAL_PLUGINS`

> _`pug-practice` image only._

Default: `false`

Disables all SourceMod plugins and enables only minimal required plugins for optimal server performance:

- `admin-flatfile`
- `botmimic`
- `csutils`
- `practicemode`
- `pugsetup`

Can be enabled with `true`. Additional plugins can be enabled with [`SOURCEMOD_PLUGINS_ENABLED`](#sourcemod_plugins_enabled).

##### `PUGSETUP_PERMISSIONS`

> _`pug-practice` image only._

Default: None

List of comma-separated PugSetup permissions (e.g. `sm_10man=none,sm_setup=admin`) that are set in `addons/sourcemod/configs/pugsetup/permissions.cfg`. Changes are applied on container start.

##### `PUGSETUP_SETUPOPTIONS`

> _`pug-practice` image only._

Default: None

List of comma-separated PugSetup configurations (e.g. `maptype=current,record=0:0`) that are set in `addons/sourcemod/configs/pugsetup/setupoptions.cfg` where the first value is the `default` value followed by an optional second value which is the `display_setting` value and a `:` delimiter in between them. Changes are applied on container start.

##### `PUGSETUP_CVARS`

> _`pug-practice` image only._

Default: None

List of comma-separated PugSetup configurations (e.g. `sm_pugsetup_autosetup=1,sm_pugsetup_quick_restarts=1`) that are set in `cfg/sourcemod/pugsetup.cfg`. Changes are applied on container start, but not on initial container start as `pugsetup.cfg` must be auto-generated first by the server.

##### `PUGSETUP_DAMAGEPRINT_CVARS`

> _`pug-practice` image only._

Default: None

List of comma-separated PugSetup configurations (e.g. `sm_pugsetup_damageprint_auto_color=1,sm_pugsetup_damageprint_format={NAME} [{HEALTH}]: {DMG_TO}/{HITS_TO}`) that are set in `cfg/sourcemod/pugsetup_damageprint.cfg`. Changes are applied on container start, but requires `pugsetup_damageprinter` plugin to be run first.

### Other

##### `VALIDATE_SERVER_FILES`

Default: `false`

Validate and restore missing/fix broken server files (incl. Metamod, SourceMod, PugSetup and PracticeMode if you're using `sourcemod` or `pug-practice` images) on container start. Can be enabled with `true`.

This should especially be used whenever custom server files have been deleted and have overwritten files before, e.g. `addons/sourcemod/configs/admins_simple.ini`, and you want to restore the original files.

##### `DEBUG`

Default: `false`

Print all executed commands for better debugging.

## Managing SourceMod Plugins

SourceMod plugins can be managed through the environment variables [`SOURCEMOD_PLUGINS_DISABLED`](#sourcemod_plugins_disabled) and [`SOURCEMOD_PLUGINS_ENABLED`](#sourcemod_plugins_enabled) where either selected (comma-separated list) or all (`*`) plugins are disabled/enabled. Plugins are disabled first and then enabled on container start.

### Example

```sh
# .env
SOURCEMOD_PLUGINS_DISABLED="*"
SOURCEMOD_PLUGINS_ENABLED="admin-flatfile,antiflood,reservedslots"
```

This will disable all plugins and enable `admin-flatfile`, `antiflood` and `reservedslots`. Using `*` is useful to disable/enable all plugins without needing to specify them individually.

The `pug-practice` image also offers a [`PUG_PRACTICE_MINIMAL_PLUGINS`](#pug_practice_minimal_plugins) environment variable that disables all SourceMod plugins and enables only minimal required plugins for PugSetup and PracticeMode for optimal server performance.

## Populating with Own Server Files

The server can be populated with your own custom server files (e.g. configs and maps) through a mounted directory that has the same folder structure as the server `csgo` folder in order to add or overwrite the files at their respective paths. Deleted custom server files, which have been added or have overwritten files before, are also removed from the `csgo` folder. The directory must be mounted at [`CSGO_CUSTOM_FILES_DIR`](#csgo_custom_files_dir) (default: `/usr/csgo`) and will be synced with the server `csgo` folder at each start of the container.

**Note:** See [`VALIDATE_SERVER_FILES`](#validate_server_files) on how to restore original files if they've been overwritten before but are removed now.

### Example

#### Host

Custom server files in `/home/user/custom-files`:

<!-- prettier-ignore-start -->
```sh
custom-files
├── addons
│   └── sourcemod
│       └── configs
│           └── admins_simple.ini # Will be overwritten
└── cfg
    └── server.cfg # Will be added
```
<!-- prettier-ignore-end -->

#### Container

`/home/user/custom-files` mounted to [`CSGO_CUSTOM_FILES_DIR`](#csgo_custom_files_dir) (default: `/usr/csgo`) in the container:

<!-- prettier-ignore-start -->
```sh
$ docker run \
  -v=csgo:/home/csgo/server \
  -v=/home/user/custom-files:/usr/csgo \ # Mount the custom files directory
  --net=host \
  timche/csgo
```
<!-- prettier-ignore-end -->

## Updating the Server

Once the server has been installed, the container will check for a server update at every container start.

### Automated (recommended)

[csgo-updater](https://hub.docker.com/r/timche/csgo-updater), a companion Docker image, is automatically watching all containers running this image and will restart them when a server update is available and the server is empty. We recommend this to update your servers without hassle.

#### Example

```sh
$ docker run -d \
  --name csgo-updater \
  -v /var/run/docker.sock:/var/run/docker.sock \
  timche/csgo-updater
```

### Manually

Restart the container with [`docker restart`](https://docs.docker.com/engine/reference/commandline/restart/).

#### Example

Container named `csgo`:

```sh
$ docker restart csgo
```
