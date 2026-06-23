#!/usr/bin/env bash
# PreToolUse hook: deny tool calls that bypass or weaken the local git
# signing / verification policy. Registered for Bash and the file-editing tools
# in home/claude.nix. PreToolUse runs before the call, so every decision is made
# from the tool input alone.
#
# Three vectors are guarded:
#   1. git command bypass  - git commit ... with -n/--no-verify/--no-gpg-sign/
#                            --no-signoff, git config writes, and inline
#                            `git -c key=val` / `--config-env` overrides.
#   2. .git/ file edits    - Write/Edit/MultiEdit/NotebookEdit whose target path
#                            is inside a .git directory (e.g. .git/config,
#                            .git/hooks/pre-commit).
#   3. .git/ bash writes    - best-effort: redirections and common mutators
#                            (rm/mv/cp/tee/chmod/sed -i/...) targeting a .git/
#                            path. Arbitrary interpreters can still reach .git;
#                            vector 2 is the authoritative file-edit guard.
#
# Allowed on purpose: read-only `git config` (--get*/--list/-l/bare key),
# `git commit -c <commitish>` (reuse a message), and reading files under .git/.
#
# Source of truth for the matcher — test-git-policy-hook.sh at the repo root
# drives this exact script. Keep them in lockstep.
set -u

payload="$(cat)"

deny() {
  printf '%s' "$payload" | jq -cn --arg reason "$1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
  exit 0
}

tool="$(printf '%s' "$payload" | jq -r '.tool_name // ""')"

# Word-boundary helpers avoid grep's \b so behaviour is identical on BSD and GNU
# grep (the hook runs whatever grep is on PATH).
WORD_GIT='(^|[^[:alnum:]])git([^[:alnum:]]|$)'
# `commit`/`config` must be the git SUBCOMMAND (git, optional global flags, then
# the word) — not the same text inside a path like .git/config or .git/COMMIT_*,
# nor an argument like `git log --grep=commit`.
GIT_COMMIT_CMD='(^|[[:space:]])git[[:space:]]+(-{1,2}[^[:space:]]+[[:space:]]+)*commit([[:space:]]|$)'
GIT_CONFIG_CMD='(^|[[:space:]])git[[:space:]]+(-{1,2}[^[:space:]]+[[:space:]]+)*config([[:space:]]|$)'

LONG_BYPASS='(^|[[:space:]])(--no-verify|--no-gpg-sign|--no-signoff)([[:space:]]|=|$)'
# A short-flag cluster containing n is -n or a group like -nm/-an (n only appears
# in `git commit`'s -n short option, so this is unambiguous after quote masking).
SHORT_BYPASS='(^|[[:space:]])-[A-Za-z]*n[A-Za-z]*([[:space:]]|$)'

CONFIG_READ='(^|[[:space:]])(--get|--get-all|--get-regexp|--get-urlmatch|--list|-l)([[:space:]]|=|$)'
CONFIG_WRITE_FLAG='(^|[[:space:]])(--add|--unset|--unset-all|--replace-all|--rename-section|--remove-section|--edit|-e)([[:space:]]|$)'
INLINE_C='(^|[[:space:]])-c[[:space:]]+[^[:space:]]*='          # git -c key=value (not git commit -c <commitish>)
INLINE_CONFIG_ENV='(^|[[:space:]])--config-env([[:space:]]|=)'

# .git path as a path component: matches .git/ and a trailing .git file, but not
# .github/ or .gitignore.
GIT_INTERNAL_PATH='(^|/)\.git(/|$)'
GIT_DIR_REF='(^|[^[:alnum:]_.-])\.git/'                         # a .git/ path referenced in a command
REDIR_TO_GIT='>>?[[:space:]]*[^|;&<>]*\.git/'
MUTATOR_CMD='(^|[[:space:]])(rm|mv|cp|tee|truncate|install|ln|chmod|chown|dd|touch|mkdir|rmdir|mktemp)([[:space:]])'
SED_IN_PLACE='(^|[[:space:]])sed([[:space:]]|$).*-i'

case "$tool" in
  Bash)
    cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // ""')"
    [ -n "$cmd" ] || exit 0

    # Mask quoted spans first so flag/path text inside a message or value can
    # neither trigger nor hide a match, then split on shell separators so a flag
    # in one command is never blamed on a git invocation in another.
    masked="$(printf '%s' "$cmd" | sed -E "s/'[^']*'/__Q__/g; s/\"[^\"]*\"/__Q__/g")"
    segments="$(printf '%s' "$masked" | awk '{gsub(/&&|\|\||;|\|/, "\n"); print}')"

    while IFS= read -r seg; do
      [ -n "$seg" ] || continue

      # 3. bash writes into a .git/ directory (best-effort).
      if printf '%s' "$seg" | grep -qE "$GIT_DIR_REF"; then
        if printf '%s' "$seg" | grep -qE "$REDIR_TO_GIT" \
           || printf '%s' "$seg" | grep -qE "$MUTATOR_CMD" \
           || printf '%s' "$seg" | grep -qE "$SED_IN_PLACE"; then
          deny "Blocked: agents may not write inside a .git directory (config, hooks). You must respect the users settings. If you are blocked ask the user for help."
        fi
      fi

      printf '%s' "$seg" | grep -qE "$WORD_GIT" || continue

      # 1a. inline config override
      if printf '%s' "$seg" | grep -qE "$INLINE_C" \
         || printf '%s' "$seg" | grep -qE "$INLINE_CONFIG_ENV"; then
        deny "Blocked: agents may not override git config inline (git -c / --config-env). You must respect the users settings. If you are blocked ask the user for help."
      fi

      # 1b. git config write (reads pass through)
      if printf '%s' "$seg" | grep -qE "$GIT_CONFIG_CMD"; then
        if ! printf '%s' "$seg" | grep -qE "$CONFIG_READ"; then
          if printf '%s' "$seg" | grep -qE "$CONFIG_WRITE_FLAG"; then
            deny "Blocked: agents may not modify git config. Reads are allowed; You must respect the users settings. If you are blocked ask the user for help."
          fi
          # A key plus a value (>=2 positional args after `config`) is a write.
          argcount="$(printf '%s' "$seg" | tr ' \t' '\n\n' \
            | grep -vE '^(git|config|-.*)$' | grep -c .)"
          if [ "$argcount" -ge 2 ]; then
            deny "Blocked: agents may not modify git config. Reads are allowed; You must respect the users settings. If you are blocked ask the user for help."
          fi
        fi
        continue
      fi

      # 1c. git commit bypass flags
      if printf '%s' "$seg" | grep -qE "$GIT_COMMIT_CMD"; then
        if printf '%s' "$seg" | grep -qE "$LONG_BYPASS" \
           || printf '%s' "$seg" | grep -qE "$SHORT_BYPASS"; then
          deny "Blocked: git commit may not bypass signing, sign-off, or hooks (--no-verify/--no-gpg-sign/--no-signoff/-n)."
        fi
      fi
    done <<EOF
$segments
EOF
    exit 0
    ;;

  Write | Edit | MultiEdit | NotebookEdit)
    path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_input.notebook_path // ""')"
    [ -n "$path" ] || exit 0
    if printf '%s' "$path" | grep -qE "$GIT_INTERNAL_PATH"; then
      deny "Blocked: agents may not edit files inside a .git directory (config, hooks). You must respect the users settings. If you are blocked ask the user for help."
    fi
    exit 0
    ;;

  *)
    exit 0
    ;;
esac
