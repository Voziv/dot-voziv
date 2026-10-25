#!/usr/bin/env bash
# WorktreeCreate hook: place `claude --worktree` worktrees under a predictable
# ~/.worktrees/<repo>/<name> tree (shared with editors that read the same
# directory, e.g. Zed's worktree switcher) instead of the default location.
# Reads Claude's JSON payload from stdin, writes the absolute path to stdout.
#
# New branches are cut from a freshly fetched origin/<default-branch> rather
# than the current local HEAD, so a worktree never starts out behind main.
# The fetch runs on every creation (including mid-session) since this hook is
# the only creation path for --worktree/background/isolation worktrees.
payload="$(cat)"
name="$(jq -r '.name' <<<"$payload")"
repo="$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")"
if [ -z "$repo" ]; then
  echo "Error: not inside a git repository." >&2
  exit 1
fi
target="$HOME/.worktrees/$repo/$name"
if [ -d "$target" ]; then
  echo "$target"
  exit 0
fi
mkdir -p "$HOME/.worktrees/$repo"

# Refresh remote refs so the base branch is current. Non-fatal: an offline
# or slow remote must never block worktree creation.
git fetch origin --quiet 2>/dev/null || true

if git show-ref --verify --quiet "refs/heads/$name"; then
  # Existing branch: check it out as-is; never move someone's branch.
  git worktree add "$target" "$name" >&2
else
  # New branch: base it on the fetched default branch when resolvable,
  # otherwise fall back to current HEAD (e.g. no remote / detached setup).
  base_ref="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"
  if [ -z "$base_ref" ]; then
    git remote set-head origin --auto >/dev/null 2>&1 || true
    base_ref="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"
  fi
  [ -z "$base_ref" ] && base_ref="origin/main"
  if git rev-parse --verify --quiet "$base_ref" >/dev/null; then
    git worktree add "$target" -b "$name" "$base_ref" >&2
  else
    git worktree add "$target" -b "$name" >&2
  fi
fi
echo "$target"
