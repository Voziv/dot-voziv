# asdf >= 0.16 is a standalone Go binary (installed via home/packages.nix) with
# no asdf.sh to source — it activates purely by putting its shims dir on PATH.
# The old `source ~/.asdf/asdf.sh` only worked for the classic shell version,
# which the nix package no longer provides. prepend_path (from rc.d) is
# idempotent, so re-sourcing this file is safe.
if command -v asdf >/dev/null 2>&1; then
  ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
  prepend_path "$ASDF_DATA_DIR/shims"

  # Register completions. Generate the file once (or after upgrades) with:
  #   asdf completion zsh > "$ASDF_DATA_DIR/completions/_asdf"
  if [[ -d "$ASDF_DATA_DIR/completions" && ${fpath[(Ie)$ASDF_DATA_DIR/completions]} -eq 0 ]]; then
    fpath=("$ASDF_DATA_DIR/completions" $fpath)
  fi
fi
