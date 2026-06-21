## macOS — residual manual steps

Most of what used to live here is now declarative in `darwin/default.nix` and gets applied by `darwin-rebuild switch --flake .#voziv-mac`. This file covers only the things nix-darwin can't automate.

Keyboard behavior (F-keys as standard function keys), the full trackpad gesture set, and hot corners are among those declarative defaults — change them in `darwin/default.nix`, not System Settings, since a manual tweak gets reverted on the next switch. Some of those changes need a logout/login to fully apply.

### One-time, before first `darwin-rebuild`

1. Install Homebrew (nix-darwin uses it as a bridge for GUI apps not in nixpkgs):
   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Install Nix via the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer) (see the main README).

### After first switch

1. **1Password SSH agent + biometric CLI**: open 1Password → Settings → Developer → enable both "Use the SSH agent" and "Integrate with 1Password CLI". This makes `op` usable without `op signin`, and SSH keys never leave 1Password.

2. **Battery toolkit** (not in a regular brew formula — needs `--no-quarantine`):
   ```sh
   brew install mhaeuser/mhaeuser/battery-toolkit --no-quarantine
   ```

3. **Docker plugin paths**: add to `~/.docker/config.json` if it isn't already (consider declaring this in `home/default.nix` via `home.file.".docker/config.json"` if you want it tracked):
   ```json
   {
     "cliPluginsExtraDirs": ["/opt/homebrew/lib/docker/cli-plugins"]
   }
   ```
   Then start colima: `colima start && brew services start colima`.

4. **JetBrains shortcuts**: the three keyboard-shortcut unbinds (CMD+Shift+M, CMD+Shift+A in Terminal Services and Spotlight finder search) are wired in `darwin/default.nix` under `system.defaults.CustomUserPreferences`. If a future macOS rev moves these keys around, a logout/login may be needed before the change takes effect.

### Things still managed by hand (not configurable via nix-darwin)

- 1Password's biometric unlock toggle
- iCloud account sign-in
- Time Machine source/destinations
