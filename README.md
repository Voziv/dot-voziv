## Voziv's portable shell configuration

Managed by **Nix flakes + home-manager** (with **nix-darwin** layered on top for macOS system config). Replaces the previous GNU Stow setup. Works on:

- Any Linux distribution (Nix runs as a single-user install on top of the host OS — no need to switch to NixOS)
- macOS (Intel or Apple Silicon)

Git identity and SSH host config are declared natively in `home/`. SSH keys themselves never touch this repo — the 1Password SSH agent handles them, and commit signing goes through 1Password's `op-ssh-sign`.

---

### First-time setup

#### 1. Clone the repo

```sh
git clone git@github.com:voziv/dot-voziv ~/dev/dot-voziv
cd ~/dev/dot-voziv
```

#### 2. Bootstrap

```sh
./install.sh
```

`install.sh` installs Nix ([Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer), flakes on by default) if it's missing, then applies the flake output matching this host's short name (`hostname -s`):

- a `homeConfigurations.<host>` → `home-manager switch`
- a `darwinConfigurations.<host>` → `darwin-rebuild switch` (macOS system config)

Configs are keyed by hostname: `voziv-pc` (this Linux box), `voziv-mac` (personal mac), `lrobert-rh` (work mac). For a **new** machine, add an entry to `flake.nix` keyed by its `hostname -s` first. On **macOS**, install Homebrew before the first run — see [`MAC.md`](MAC.md).

> ⚠️ home-manager refuses to overwrite pre-existing unmanaged files. If `~/.ssh/config` (or another managed path) already exists, back it up first, or pass `-b bak` to the underlying switch.

#### 3. Reload your shell

```sh
exec zsh
```

You should see the pure prompt and have `dev-status`, `switch-voziv`, `vserver`, and the other custom scripts on `$PATH`. After this first switch, the `hms` alias re-applies the config on either bash or zsh.

---

### Day-to-day

| Action | Command |
|---|---|
| Apply changes after editing nix files (home) | `hms` (alias → `home-manager switch --flake ~/dev/dot-voziv#$(hostname -s)`) |
| Apply changes after editing nix files (Mac)  | `darwin-rebuild switch --flake ~/dev/dot-voziv#voziv-mac` |
| Bootstrap / re-apply on any machine | `./install.sh` |
| Bump pinned nixpkgs | `nix flake update` (then switch) |
| View generations | `home-manager generations` |
| Roll back | `home-manager switch --switch-generation <N>` |
| Add a tool to the env | edit `home/packages.nix`, switch |

---

### Repo layout

```
dot-voziv/
├── flake.nix              # inputs (nixpkgs, home-manager, nix-darwin) + outputs per host
├── install.sh             # bootstrap: install Nix + apply this host's flake config
├── home/                  # home-manager modules (bash, zsh, ssh, git, tmux, neovim, packages)
├── darwin/                # nix-darwin module — macOS defaults + Homebrew bridge
└── src/                   # files symlinked into $HOME by home-manager
    ├── .gitignore_global  # global .gitignore → ~/.gitignore_global (referenced from home/git.nix)
    └── .voziv/            # modular shell tree — symlinked by home-manager, sourced by bash + zsh
        ├── bin/               # custom executables (dev-status, switch-*, vserver, …)
        ├── rc.d/              # cross-shell modules (platform detection, paths, aliases, NVM, 1P SSH agent)
        ├── zshrc.d/           # zsh-only modules (completions, asdf, global aliases)
        ├── envs/              # environment templates for switch-* scripts
        └── openssl/           # local CA / cert configs
```

`rc.d/*.sh` is POSIX and sourced by **both** bash and zsh; `zshrc.d/*.zsh` is zsh-only. Shared aliases and env live natively in `home/default.nix` (`home.shellAliases` / `home.sessionVariables`). The historical stow files (`src/.zshrc`, `src/.bashrc`, `src/.gitconfig`, `src/.tmux.conf`, `src/.vimrc`, the `bashrc.d/` tree, the `pure` prompt submodule, and the `01-zshrc`/`02-oh-my`/`02-pure` zshrc modules) have all been replaced by native modules in `home/`.

---

### Known sharp edges

- **Pre-existing files collide on first switch**: home-manager refuses to overwrite unmanaged files. `~/.ssh/config` is the common one (now managed via `home/ssh.nix`) — back it up or pass `-b bak` to the first switch. Migrating off stow? Run `stow -D -t $HOME src` first.
- **SSH host config is committed**: `home/ssh.nix` declares the `voziv-*` hosts and the 1Password `IdentityAgent` directly in this (public) repo. Keep genuinely sensitive hosts out of it.
- **`op` CLI access**: requires a 1Password account with CLI enabled. Some enterprise SSO setups block it; verify per-account before depending on it.
- **NVM**: stays runtime-managed via `rc.d/20-nvm.sh`. Nix can't cleanly manage NVM's `~/.nvm` state; leave it alone.
