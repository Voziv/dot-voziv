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
