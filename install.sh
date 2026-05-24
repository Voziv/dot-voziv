#!/usr/bin/env bash
#
# Bootstrap this machine onto the Nix configuration in this repo.
#
# Installs Nix (Determinate Systems installer, flakes enabled) if it is
# missing, then applies the flake output matching this host's short name
# (`hostname -s`):
#   - a darwinConfigurations.<host>  → nix-darwin (darwin-rebuild)
#   - a homeConfigurations.<host>    → home-manager (standalone)
#
# Idempotent: safe to re-run. Re-running just re-applies the current config.

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
host="$(hostname -s)"
nix_flags=(--extra-experimental-features "nix-command flakes")

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

install_nix() {
  if command -v nix >/dev/null 2>&1; then
    log "Nix already installed ($(nix --version))"
    return
  fi
  log "Installing Nix (Determinate Systems installer)…"
  curl --proto '=https' --tlsv1.2 -sSfL https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # Load nix into the current shell so the apply step can use it immediately.
  for profile in \
    /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
    "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
    # shellcheck disable=SC1090
    [ -e "$profile" ] && . "$profile" && break
  done
}

# True if the flake exposes <output-set>.<host> (e.g. homeConfigurations.voziv-pc).
flake_has() {
  nix "${nix_flags[@]}" eval --json "${repo_dir}#$1" --apply 'builtins.attrNames' 2>/dev/null \
    | grep -q "\"${host}\""
}

apply() {
  if flake_has darwinConfigurations; then
    log "Applying nix-darwin config: ${host}"
    if command -v darwin-rebuild >/dev/null 2>&1; then
      sudo darwin-rebuild switch --flake "${repo_dir}#${host}"
    else
      log "Bootstrapping nix-darwin (first run)…"
      sudo nix "${nix_flags[@]}" run nix-darwin -- switch --flake "${repo_dir}#${host}"
    fi
  elif flake_has homeConfigurations; then
    log "Applying home-manager config: ${host}"
    nix "${nix_flags[@]}" run home-manager/master -- switch --flake "${repo_dir}#${host}"
  else
    cat >&2 <<EOF
No flake output found for host '${host}'.

Add an entry to flake.nix (homeConfigurations or darwinConfigurations) keyed
by '${host}', or apply an explicit one:
  home-manager switch --flake ${repo_dir}#<name>
EOF
    exit 1
  fi
}

install_nix
apply
log "Done. Open a new shell (e.g. 'exec zsh') to load the new environment."
