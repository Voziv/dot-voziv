## Setting up mac

In the future I want to set this all up so nix handles all the setup and configuration

### Settings

- Unbind open man page hotkey `CMD+Shift+M` (Keyboard Shortcuts -> Services -> Text -> Open Man Page in Terminal)
- Unbind search man page hotkey `CMD+Shift+A` (Keyboard Shortcuts -> Services -> Text -> Search man Page Index in Terminal)
- Unbind finder search hotkey `CMD+Shift+A` (Keyboard Shortcuts -> Spotlight -> Show Finder search window)

### Apps to install

- 1Password
- Discord
- Jetbrains Toolbox
- Logi Options+ (get offline installer, only used for MX Master mouse)
- Magic-Switch
- Spotify
- Todoist
- Zen Browser


### QoL

```shell
brew tap mhaeuser/mhaeuser
brew install battery-toolkit --no-quarantine
```

### Docker

```shell
brew install docker
brew install docker-compose
brew install docker-buildx
brew install colima

colima start
colima start
brew services start colima

```

Add the following to `~/.docker/config.json`
```json
"cliPluginsExtraDirs": [
  "/opt/homebrew/lib/docker/cli-plugins"
]
```


### PHP & Node

```shell
brew install php
brew install composer
brew install nvm
```