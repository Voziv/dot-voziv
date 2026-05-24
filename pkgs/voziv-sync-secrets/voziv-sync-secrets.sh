#!/usr/bin/env bash
# voziv-sync-secrets — render 1Password-templated configs into ~/.voziv.
#
# Idempotent: same templates + same vault state → byte-identical files every run.
# Safe to invoke any time you rotate or update a secret in 1Password.
#
# Each (template → dest) pair is rendered via `op inject`, written to a
# temp file, chmod'd to 0600, and atomically moved into place. If `op`
# dies mid-render, the existing dest file is untouched.

set -euo pipefail

if ! command -v op >/dev/null 2>&1; then
  echo "voziv-sync-secrets: 1Password CLI (op) not found on PATH" >&2
  exit 1
fi

if ! op whoami >/dev/null 2>&1; then
  cat >&2 <<'EOF'
voziv-sync-secrets: not signed in to 1Password.

Sign in with one of:
  eval "$(op signin)"
or enable "Integrate with 1Password CLI" in the desktop app's Developer
settings to use biometric unlock.
EOF
  exit 1
fi

VOZIV_DIR="${VOZIV_DIR:-$HOME/.voziv}"

# (template-relative-path, destination-relative-path)
templates=(
  "ssh/voziv_config.tpl:ssh/voziv_config"
)

exit_code=0

for pair in "${templates[@]}"; do
  src_rel="${pair%%:*}"
  dst_rel="${pair##*:}"
  src="$VOZIV_DIR/$src_rel"
  dst="$VOZIV_DIR/$dst_rel"

  if [ ! -f "$src" ]; then
    echo "skip: template missing — $src" >&2
    continue
  fi

  mkdir -p "$(dirname "$dst")"

  tmp="$(mktemp "$dst.XXXXXX")"
  trap 'rm -f "$tmp"' EXIT

  if op inject --force --in-file "$src" --out-file "$tmp"; then
    chmod 600 "$tmp"
    mv -f "$tmp" "$dst"
    echo "synced: $dst"
  else
    rm -f "$tmp"
    echo "error: render failed for $src" >&2
    exit_code=1
  fi

  trap - EXIT
done

exit "$exit_code"
