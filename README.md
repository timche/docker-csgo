# docker-csgo

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

> [Counter-Strike: Global Offensive (CS:GO) Dedicated Server](https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers) with automatic/manual updates and optional [SourceMod](https://www.sourcemod.net/) and [PugSetup](https://github.com/splewis/csgo-pug-setup)/[PracticeMode](https://github.com/splewis/csgo-practice-mode) integrations

## How to Use This Image

```sh
$ docker run \
  -v=csgo:/home/csgo/server \
  --net=host \
  timche/csgo
```

- The server will be installed on a volume named `csgo` to [ensure persistence of server files](https://docs.docker.com/storage/).
- The server will be running on the default port `27015` on the `host` network for [optimal network performance](https://docs.docker.com/network/host/)
- The server will be running in LAN mode since a [Game Server Login Token](#csgo_gslt) (GSLT) is required to run the server on the internet.

## Image Variants

Each variant refers to a tag, e.g. `timche/csgo:<tag>`.

#### [`latest`](https://github.com/timche/docker-csgo/blob/master/base/Dockerfile) / [`<version>`](https://github.com/timche/docker-csgo/blob/master/base/Dockerfile)

CS:GO server without any modifications or add-ons.

#### [`sourcemod`](https://github.com/timche/docker-csgo/blob/master/sourcemod/Dockerfile) / [`<version>-sourcemod`](https://github.com/timche/docker-csgo/blob/master/sourcemod/Dockerfile)

CS:GO server with [Metamod:Source](https://www.sourcemm.net) and [SourceMod](https://www.sourcemod.net/).

#### [`pug-practice`](https://github.com/timche/docker-csgo/blob/master/pug-practice/Dockerfile) / [`<version>-pug-practice`](https://github.com/timche/docker-csgo/blob/master/pug-practice/Dockerfile)

CS:GO server with [Metamod:Source](https://www.sourcemm.net), [SourceMod](https://www.sourcemod.net/), [PugSetup](https://github.com/splewis/csgo-pug-setup) and [PracticeMode](https://github.com/splewis/csgo-practice-mode) (by [splewis](https://github.com/splewis)).

## Environment Variables

### `CSGO_GSLT`

Default: None

Your Game Server Login Token (GSLT) if you want to run the server on the internet.

- [Get GSLT](https://steamcommunity.com/dev/managegameservers)
- [What is GSLT?](https://docs.linuxgsm.com/steamcmd/gslt#what-is-gslt)
- [FAQ](https://docs.linuxgsm.com/steamcmd/gslt#faq)

### `CSGO_WS_API_KEY`

Default: None

Your [Steam Web API Key](https://steamcommunity.com/dev/apikey) to download workshop maps.

### `CSGO_IP`

Default: `0.0.0.0`

Internet IP the server is accessible from. In most cases the default value is sufficient, but if you want to run a [GOTV server](https://developer.valvesoftware.com/wiki/SourceTV) or have issues connecting to the server, setting the IP can help.

### `CSGO_PORT`

Default: `27015`

Port the server is listening to.

### `CSGO_MAP`

Default: `de_dust2`

Start the server with a specific map.

### `CSGO_MAX_PLAYERS`

Default: `16`

Maximum players allowed to join the server.

### `CSGO_HOSTNAME`

Default: `Counter-Strike: Global Offensive`

The server name. [It can't contain spaces](https://developer.valvesoftware.com/wiki/Command_Line_Options#Some_useful_console_variables_2), so if you need a server name with spaces, set `hostname` in a config instead, e.g. `server.cfg`.

### `CSGO_RCON_PW`

Default: `changeme`

RCON password to administrate the server.

### `CSGO_PW`

Default: None

Password to join the server.

### `CSGO_TICKRATE`

Default: `128`

Server tick rate which can be `64` or `128`. The default value gives the best game experience, but also requires most server hardware resources.

### `CSGO_GAME_TYPE`

Default: `0` (Competitive)

[Game type](https://developer.valvesoftware.com/wiki/CSGO_Game_Mode_Commands).

### `CSGO_GAME_MODE`

Default: `1`

[Game mode](https://developer.valvesoftware.com/wiki/CSGO_Game_Mode_Commands).

### `CSGO_MAP_GROUP`

Default: `mg_active`

Map group.

### `CSGO_CUSTOM_FILES_DIR`

Default: `/usr/csgo`

Absolute path to a directory in the container containing custom server files. Changing this is not recommended in order to follow the documentation. See more at "[Populating with Own Server Files](#populating-with-own-server-files)".

### `CSGO_PARAMS`

Additional `srcds_run` [parameters](https://developer.valvesoftware.com/wiki/Command_Line_Options#Command-line_parameters).

### `METAMOD_VERSION`

> _`sourcemod`, `pug-practice` image only._

Default: `1.10.7`

[Metamod:Source version](https://www.sourcemm.net/downloads.php?branch=stable) running on the server. Changing this will update/downgrade it on container start.

### `METAMOD_BUILD`

> _`sourcemod`, `pug-practice` image only._

Default: `971`

[Metamod:Source build number](https://www.sourcemm.net/downloads.php?branch=stable) running on the server. Changing this will update/downgrade it on container start. Build number must exist at version.

### `SOURCEMOD_VERSION`

> _`sourcemod`, `pug-practice` image only._

Default: `1.10.0`

[SourceMod version](https://www.sourcemod.net/downloads.php?branch=stable) running on the server. Changing this will update/downgrade it on container start.

### `SOURCEMOD_BUILD`

> _`sourcemod`, `pug-practice` image only._

Default: `6488`

[SourceMod build number](https://www.sourcemod.net/downloads.php?branch=stable) running on the server. Changing this will update/downgrade it on container start. Build number must exist at version.

### `SOURCEMOD_PLUGINS_DISABLED`

> _`sourcemod`, `pug-practice` image only._

Default: None

List of comma-separated SourceMod plugins (e.g. `nextmap,reservedslots,sounds`) that are disabled. `*` disables all plugins. The plugins are moved into the `disabled` folder on container start. This is running before `SOURCEMOD_PLUGINS_ENABLED`.

### `SOURCEMOD_PLUGINS_ENABLED`

> _`sourcemod`, `pug-practice` image only._

Default: None

List of comma-separated SourceMod plugins (e.g. `mapchooser,randomcycle,rockthevote`) that are enabled. `*` enables all plugins. The plugins are moved out of the `disabled` folder into `plugins` on container start. This is running after `SOURCEMOD_PLUGINS_DISABLED`.

### `PUGSETUP_VERSION`

> _`pug-practice` image only._

Default: `2.0.5`

[PugSetup version](https://github.com/splewis/csgo-pug-setup/releases) running on the server. Changing this will update/downgrade it on container start.

### `PRACTICEMODE_VERSION`

> _`pug-practice` image only._

Default: `1.3.3`

[PracticeMode version](https://github.com/splewis/csgo-practice-mode/releases) running on the server. Changing this will update/downgrade it on container start.

### `PUG_PRACTICE_MINIMAL_PLUGINS`

> _`pug-practice` image only._

Default: `false`

Disables all SourceMod plugins and enables only minimal required plugins for optimal server performance:

- `admin-flatfile`
- `botmimic`
- `csutils`
- `practicemode`
- `pugsetup`

Can be enabled with `true`. Additional plugins can be enabled with [`SOURCEMOD_PLUGINS_ENABLED`](#sourcemod_plugins_enabled).

### `PUGSETUP_AUTOKICKER`

> _`pug-practice` image only._

Default: `false`

Enable [`pugsetup_autokicker`](https://github.com/splewis/csgo-pug-setup#pugsetup_autokicker) plugin. Only works with `PUG_PRACTICE_MINIMAL_PLUGINS` set to `true`.

### `PUGSETUP_TEAMLOCKER`

> _`pug-practice` image only._

Default: `false`

Enable [`pugsetup_teamlocker`](https://github.com/splewis/csgo-pug-setup#pugsetup_teamlocker) plugin. Only works with `PUG_PRACTICE_MINIMAL_PLUGINS` set to `true`.

### `PUGSETUP_DAMAGEPRINT`

> _`pug-practice` image only._

Default: `false`

Enable [`pugsetup_damageprint`](https://github.com/splewis/csgo-pug-setup#pugsetup_damageprint) plugin. Only works with `PUG_PRACTICE_MINIMAL_PLUGINS` set to `true`.

### `PUGSETUP_TEAMNAMES`

> _`pug-practice` image only._

Default: `false`

Enable [`pugsetup_teamnames`](https://github.com/splewis/csgo-pug-setup#pugsetup_teamnames) plugin. Only works with `PUG_PRACTICE_MINIMAL_PLUGINS` set to `true`.

## Populating with Own Server Files

The server can be populated with your own custom server files (e.g. configs and maps) through a mounted directory that has the same folder structure as the server `csgo` folder in order to add or overwrite the files at their respective paths. The directory must be mounted at [`CSGO_CUSTOM_FILES_DIR`](#csgo_custom_files_dir) (default: `/usr/csgo`) and will be synced with the server `csgo` folder at each start of the container.

### Example

#### Host

Custom server files in `/home/user/custom-files`:

```sh
custom-files
├── addons
│   └── sourcemod
│       └── configs
│           └── admins_simple.ini # Will be overwritten
└── cfg
    └── server.cfg # Will be added
```

#### Container

`/home/user/custom-files` mounted to [`CSGO_CUSTOM_FILES_DIR`](#csgo_custom_files_dir) (default: `/usr/csgo`) in the container:

```sh
$ docker run \
  -v=csgo:/home/csgo/server \
  -v=/home/user/custom-files:/usr/csgo \ # Mount the custom files directory
  --net=host \
  timche/csgo
```

## Managing SourceMod Plugins

SourceMod plugins can be managed through the environment variables [`SOURCEMOD_PLUGINS_DISABLED`](#sourcemod_plugins_disabled) and [`SOURCEMOD_PLUGINS_ENABLED`](#sourcemod_plugins_enabled) where either selected (comma-separated list) or all (`*`) plugins are disabled/enabled. Plugins are disabled first and then enabled on container start.

### Example

```sh
# .env
SOURCEMOD_PLUGINS_DISABLED="*"
SOURCEMOD_PLUGINS_ENABLED="admin-flatfile,antiflood,reservedslots"
```

This will disable all plugins and enable `admin-flatfile`, `antiflood` and `reservedslots`. Using `*` is useful to disable/enable all plugins without needing to specify them individually.

The `pug-practice` image also offers a [`PUG_PRACTICE_MINIMAL_PLUGINS`](#pug_practice_minimal_plugins) environment variable that disables all SourceMod plugins and enables only minimal required plugins for PugSetup and PracticeMode and optimal server performance. Optionally [`PUGSETUP_AUTOKICKER`](#pugsetup_autokicker), [`PUGSETUP_TEAMLOCKER`](#pugsetup_teamlocker), [`PUGSETUP_DAMAGEPRINT`](#pugsetup_damageprint) and [`PUGSETUP_TEAMNAMES`](#pugsetup_teamnames) can be set as well to enables these additional [PugSetup plugins](https://github.com/splewis/csgo-pug-setup#addon-plugins).

## Updating the Server

Once the server has been installed, the container will check for a server update at every container start.

### Automatically (recommended)

[csgo-updater](https://hub.docker.com/r/timche/csgo-updater), a companion Docker image, is automatically watching all containers running this image and will restart them when a server update is available. We recommend this to update your servers without hassle.

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
