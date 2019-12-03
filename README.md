# docker-csgo

> [CS:GO Dedicated Server](https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers) with [Metamod:Source](https://www.sourcemm.net/), [SourceMod](https://www.sourcemod.net/), [csgo-pug-setup](https://github.com/splewis/csgo-pug-setup) and [csgo-practice-mode](https://github.com/splewis/csgo-practice-mode)

## How to Use This Image

```
$ docker run \
  -v=csgo:/home/csgo/server \
  --net=host \
  timche/csgo
```

- The server will be installed on a named volume `csgo` to [persist the server files](https://docs.docker.com/storage/).
- The server will be running on the default port `27015` on the `host` network for [optimal network performance](https://docs.docker.com/network/host/)
- The server will be running in LAN mode since a Game Server Login Token (GSLT) is required to run the server on the internet.

### Game Server Login Token (GSLT)

- [Get GSLT](https://steamcommunity.com/dev/managegameservers)
- [What is GSLT?](https://docs.linuxgsm.com/steamcmd/gslt#what-is-gslt)
- [FAQ](https://docs.linuxgsm.com/steamcmd/gslt#faq)

### Environment Variables

##### `CSGO_GSLT`

Your [Game Server Login Token](https://steamcommunity.com/dev/managegameservers) if you want to run the server on the internet.

##### `CSGO_WS_API_KEY`

Your [Steam Web API Key](https://steamcommunity.com/dev/apikey) to download workshop maps.

##### `CSGO_PORT`

Default: `27015`

The port the server is listening to.

##### `CSGO_MAP`

Default: `de_dust2`

Start the server with a specific map.

##### `CSGO_MAX_PLAYERS`

Default: `12`

The maximum players allowed to join the server.

##### `CSGO_HOSTNAME`

Default: `Counter-Strike: Global Offensive`

The server name.

##### `CSGO_RCON_PW`

Default: none

The RCON password to administrate the server.

##### `CSGO_PW`

Default: none

The password to join the server.

##### `CSGO_TICKRATE`

Default: `128`

The server game tick interval.

##### `CSGO_GAME_TYPE`

Default: `0` (Competitive)

The [game mode](https://developer.valvesoftware.com/wiki/CSGO_Game_Mode_Commands) (based on game type).

##### `CSGO_GAME_MODE`

Default: `1`

The [game type]((https://developer.valvesoftware.com/wiki/CSGO_Game_Mode_Commands)).

##### `CSGO_MAP_GROUP`

Default: `mg_active`

The map group.

##### `CSGO_CUSTOM_CONFIGS_DIR`

Default: `/var/csgo`

Absolute path to a directory in the container containing custom config files. Changing this is not recommended in order to follow the documentation.

##### `CSGO_DEBUG`

Print commands in the log.

##### `CSGO_PARAMS`

Additional [parameters](https://developer.valvesoftware.com/wiki/Command_Line_Options#Command-line_parameters) to pass to `srcds_run`.

### Advanced Configuration

The server can be populated with own config files by copying the files from the custom configs directory located at [`CSGO_CUSTOM_CONFIGS_DIR`](#csgo_custom_configs_dir) to the `csgo` folder at each start of the container. [`CSGO_CUSTOM_CONFIGS_DIR`](#csgo_custom_configs_dir) is a mounted directory from the host system. The custom configs directory must have same folder structure as the `csgo` folder in order to add or overwrite the files at the paths.

#### Example

##### Host

Add configs to `/home/user/csgo`:

```
.
├── addons
│   └── sourcemod
│       └── configs
│           └── admins_simple.ini # Will be overwritten
└── cfg
    └── server.cfg # Will be added
```

##### Container

Mount `/home/user/custom-configs` to [`CSGO_CUSTOM_CONFIGS_DIR`](#csgo_custom_configs_dir) in the container:

```
$ docker run \
  -v=csgo:/home/csgo/server \
  -v=/home/user/csgo:/var/csgo \ # Mount the custom configs directory
  --net=host \
  timche/csgo
```

### Updating the Server

Once the server has been installed, the container will check for an update at every start.

#### Manually

Restart the container with [`docker restart`](https://docs.docker.com/engine/reference/commandline/restart/).

##### Example

Container named `csgo`:

```
$ docker restart csgo
```