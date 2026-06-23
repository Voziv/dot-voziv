---
paths:
  - "**/*.nix"
---

# Nix / home-manager conventions

- Two-space indentation; no tabs.
- Never hardcode the home directory. Use `${config.home.homeDirectory}` so paths
  resolve on every host (`/home/voziv`, `/Users/voziv`, `/Users/lee.robert`).
- When a directory must stay writable (an app writes into it), link individual
  files via `home.file."dir" = { source = ...; recursive = true; }` rather than
  symlinking the whole directory read-only into the Nix store.
- Reference repo files as `"${self}/src/..."`, matching the existing modules.
- Keep `home.stateVersion` pinned; never bump it after the first switch.

## Homebrew: trusting non-official taps

Homebrew 6.x (and Workbrew) refuses to load casks/formulae from non-official
taps unless trusted (`HOMEBREW_REQUIRE_TAP_TRUST`). Our nix-darwin's `homebrew`
module emits `trusted: true` into the generated Brewfile for *every* entry by
default, so packages from non-official taps load with no extra config — just
list them by their fully-qualified `user/tap/name`:

```nix
casks = [ "boltops-tools/software/terraspace" ];
brews = [ "coleam00/archon/archon" ];  # the FQN implies the tap
```

To override the default (e.g. opt an entry out of trust) or to express intent
explicitly, declare it as an attrset — works for `taps`, `brews`, and `casks`:

```nix
taps  = [ { name = "coleam00/archon"; trusted = true; } ];
casks = [ { name = "some/untrusted/thing"; trusted = false; } ];
```

`brew bundle` grants trust *only* from this Brewfile annotation (`installer.rb`
applies it before loading entries) — it ignores an on-disk
`~/.homebrew/trust.json` during the bundle's fetch/load phase, so writing a trust
file in an activation script does not work.
