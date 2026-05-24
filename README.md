## Voziv's portable shell configuration

Managed by **Nix flakes + home-manager** (with **nix-darwin** layered on top for macOS system config). Replaces the previous GNU Stow setup. Works on:

- Any Linux distribution (Nix runs as a single-user install on top of the host OS — no need to switch to NixOS)
- macOS (Intel or Apple Silicon)

Secrets (private git config, SSH config) are rendered from 1Password via a small CLI called `voziv-sync-secrets`. The 1Password SSH agent continues to handle SSH keys — they never touch this repo.

---

### First-time setup

#### 1. Install Nix

Use the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer) (multi-user mode, with flakes enabled by default):

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Open a new shell so `nix` is on `$PATH`.

#### 2. Clone the repo

```sh
git clone git@github.com:voziv/dot-voziv ~/dev/dot-voziv
cd ~/dev/dot-voziv
```

#### 3. Apply the configuration

**Linux** (CachyOS, Pop!_OS, Ubuntu, Arch, whatever):

```sh
# If you previously installed via stow, undo first to avoid collisions:
#   stow -D -t $HOME src

nix run home-manager/master -- switch --flake ".#$(hostname -s)"
```

Home configs are keyed by short hostname (`hostname -s`): `voziv-pc` (this Linux
box), `voziv-mac` (personal mac), `lrobert-rh` (work mac). After the first switch,
the `hms` alias runs this for you.

**macOS** (first machine only — installs nix-darwin, then applies):

```sh
# nix-darwin bootstrap (one-time per host)
nix run nix-darwin -- switch --flake .#voziv-mac

# Subsequent rebuilds (once `darwin-rebuild` is on $PATH)
darwin-rebuild switch --flake .#voziv-mac
```

If your Mac's hostname isn't `voziv-mac`, edit `flake.nix` → `darwinConfigurations` to add an entry matching `hostname -s`, or pass `--flake .#<hostname>`.

#### 4. Sync SSH config from 1Password

Git identity (name, email, signing key) lives declaratively in `home/git.nix` — no 1Password step is needed for git. SSH host config, however, is templated from 1Password (host aliases, internal hostnames, usernames).

Edit `src/.voziv/ssh/voziv_config.tpl` so the `op://Vault/Item/Field` references point at your actual 1Password items (right-click any field → "Copy Secret Reference" in the 1Password app). Then:

```sh
eval "$(op signin)"          # or use the desktop app's CLI integration
voziv-sync-secrets
```

Re-run `voziv-sync-secrets` any time you rotate or update a referenced field in 1Password. It's **idempotent** — same templates + same vault state → byte-identical output every run.

#### 5. Reload your shell

```sh
exec zsh
```

You should see the pure prompt and have `dev-status`, `switch-voziv`, `vserver`, and the other custom scripts on `$PATH`.

---

### Day-to-day

| Action | Command |
|---|---|
| Apply changes after editing nix files (home) | `hms` (alias → `home-manager switch --flake ~/dev/dot-voziv#$(hostname -s)`) |
| Apply changes after editing nix files (Mac)  | `darwin-rebuild switch --flake ~/dev/dot-voziv#voziv-mac` |
| Re-sync 1Password secrets | `voziv-sync-secrets` |
| Bump pinned nixpkgs | `nix flake update` (then switch) |
| View generations | `home-manager generations` |
| Roll back | `home-manager switch --switch-generation <N>` |
| Add a tool to the env | edit `home/packages.nix`, switch |

---

### Repo layout

```
dot-voziv/
├── flake.nix              # inputs (nixpkgs, home-manager, nix-darwin) + outputs per host
├── home/                  # home-manager modules (zsh, git, tmux, neovim, packages, secrets)
├── darwin/                # nix-darwin module — macOS defaults + Homebrew bridge
├── pkgs/voziv-sync-secrets/   # 1Password-CLI-based secret renderer
└── src/                   # files symlinked into $HOME by home-manager
    ├── .gitignore_global  # global .gitignore → ~/.gitignore_global (referenced from home/git.nix)
    └── .voziv/            # legacy modular shell tree — still in use, symlinked by home-manager
        ├── bin/               # custom executables (dev-status, switch-*, vserver, …)
        ├── rc.d/              # cross-shell modules (platform detection, paths, NVM, 1P SSH agent)
        ├── zshrc.d/           # zsh-specific modules NOT yet migrated to native nix
        ├── envs/              # environment templates for switch-* scripts
        └── ssh/voziv_config.tpl   # 1Password template → rendered by voziv-sync-secrets
```

The historical `src/.zshrc`, `src/.gitconfig`, `src/.tmux.conf`, and the `02-oh-my.zsh` / `02-pure.zsh` / `01-zshrc.zsh` modules under `zshrc.d/` have been replaced by native home-manager modules in `home/`. The `rc.d/` modules stay as-is because they handle runtime platform detection that buys nothing from nix-ification.

---

### Known sharp edges

- **`op` CLI access**: requires a 1Password account with CLI enabled. Some enterprise SSO setups block it; verify per-account before depending on it.
- **First-time switch on a stow'd machine**: home-manager refuses to overwrite existing files. Run `stow -D -t $HOME src` first, or pass `--backup-extension=.stowbak` to the first switch.
- **NVM**: stays runtime-managed via `rc.d/20-nvm.sh`. Nix can't cleanly manage NVM's `~/.nvm` state; leave it alone.
