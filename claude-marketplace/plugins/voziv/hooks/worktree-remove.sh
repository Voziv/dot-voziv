#!/usr/bin/env bash
# WorktreeRemove hook: safely tear down a worktree on removal, but refuse if it
# has uncommitted changes so in-progress work is never silently lost.
payload="$(cat)"
path="$(jq -r '.worktree_path' <<<"$payload")"
if [ -z "$path" ] || [ "$path" = null ] || [ ! -d "$path" ]; then
  exit 0
fi
cd "$path" || exit 1
if ! git diff-index --quiet HEAD --; then
  echo "Warning: uncommitted changes in $path. Skipping auto-removal." >&2
  exit 0
fi
cd "$HOME" || exit 1
git worktree remove "$path" >&2
