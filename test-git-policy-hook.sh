#!/usr/bin/env bash
# Test harness for the git-policy PreToolUse hook
# (src/.claude/hooks/block-git-policy.sh, wired up in home/claude.nix).
#
# It drives the REAL hook script — no reimplementation — so there is no drift to
# guard against. Each case declares the DESIRED verdict (the CORRECT behaviour,
# not whatever the hook currently does). Mismatches are reported as:
#   FALSE POSITIVE  rule blocked something it should have allowed
#   FALSE NEGATIVE  rule allowed a bypass it should have blocked
# Exit status is non-zero if any case mismatches, so this doubles as a
# regression test and as the spec we drive the matcher toward.

set -u

HOOK="$(cd "$(dirname "$0")" && pwd)/src/.claude/hooks/block-git-policy.sh"
[ -f "$HOOK" ] || { echo "Hook not found: $HOOK" >&2; exit 2; }

# Returns 0 (BLOCK) if the hook emits a deny decision for this tool call.
hook_would_block() {
  local tool="$1" payload out
  case "$tool" in
    Bash) payload="$(jq -n --arg c "$2" '{tool_name:"Bash", tool_input:{command:$c}}')" ;;
    *)    payload="$(jq -n --arg t "$tool" --arg p "$2" '{tool_name:$t, tool_input:{file_path:$p}}')" ;;
  esac
  out="$(printf '%s' "$payload" | bash "$HOOK")"
  printf '%s' "$out" | grep -q '"permissionDecision":"deny"'
}

# Format: DESIRED|tool|description|argument(command or path)
cases=(
  # === Vector 1a: commit bypass flags — must BLOCK ===
  'BLOCK|Bash|bare --no-verify|git commit --no-verify'
  'BLOCK|Bash|bare -n|git commit -n'
  'BLOCK|Bash|--no-gpg-sign|git commit --no-gpg-sign'
  'BLOCK|Bash|--no-signoff|git commit --no-signoff'
  'BLOCK|Bash|message then --no-verify|git commit -m "wip" --no-verify'
  'BLOCK|Bash|-am with -n|git commit -am "wip" -n'
  'BLOCK|Bash|add then commit --no-verify|git add -A && git commit --no-verify -m "x"'
  'BLOCK|Bash|grouped short flags -nm|git commit -nm "wip"'

  # === Vector 1a: commit — must ALLOW (these were the false positives) ===
  'ALLOW|Bash|plain message|git commit -m "normal message"'
  'ALLOW|Bash|bare commit (opens editor)|git commit'
  'ALLOW|Bash|rebase then commit|git rebase main && git commit -m "squash"'
  'ALLOW|Bash|message mentions --no-verify|git commit -m "fix the --no-verify documentation"'
  'ALLOW|Bash|message mentions -n|git commit -m "add -n flag to parser"'
  'ALLOW|Bash|message mentions --no-gpg-sign|git commit -m "explain --no-gpg-sign behavior"'
  'ALLOW|Bash|--message= mentions --no-verify|git commit --message="use --no-verify in CI"'
  'ALLOW|Bash|unrelated grep -n after commit|git commit -m "wip" && grep -n TODO file.js'
  'ALLOW|Bash|unrelated echo -n after commit|git commit -m "done"; echo -n finished'
  'ALLOW|Bash|log piped to grep -n commit|git log --oneline | grep -n commit'
  'ALLOW|Bash|commit -c reuse message|git commit -c HEAD~1'

  # === Vector 1b/1c: config writes & inline overrides — must BLOCK ===
  'BLOCK|Bash|config set key value|git config user.name "Agent"'
  'BLOCK|Bash|config --global write|git config --global commit.gpgsign false'
  'BLOCK|Bash|config disable hooks path|git config --local core.hooksPath /dev/null'
  'BLOCK|Bash|config --unset|git config --unset commit.gpgsign'
  'BLOCK|Bash|config --add|git config --add safe.directory /repo'
  'BLOCK|Bash|config --edit|git config -e'
  'BLOCK|Bash|inline -c gpgsign then commit|git -c commit.gpgsign=false commit -m "x"'
  'BLOCK|Bash|inline -c hookspath|git -c core.hooksPath=/dev/null commit'
  'BLOCK|Bash|--config-env override|git --config-env=user.name=ENVVAR commit'

  # === config reads — must ALLOW ===
  'ALLOW|Bash|config --get|git config --get user.name'
  'ALLOW|Bash|config --list|git config --list'
  'ALLOW|Bash|config -l|git config -l'
  'ALLOW|Bash|config bare key read|git config user.email'
  'ALLOW|Bash|config --get-regexp|git config --get-regexp "^user"'

  # === Vector 2: .git/ file edits via tools — must BLOCK ===
  'BLOCK|Write|write .git/config|.git/config'
  'BLOCK|Edit|edit .git/config|/repo/.git/config'
  'BLOCK|Edit|disable a hook|/repo/.git/hooks/pre-commit'
  'BLOCK|MultiEdit|multiedit .git/config|.git/config'
  'BLOCK|Write|absolute .git path|/Users/x/proj/.git/hooks/pre-push'

  # === Vector 2: lookalikes — must ALLOW ===
  'ALLOW|Edit|.gitignore is not .git|/repo/.gitignore'
  'ALLOW|Write|.github workflow|/repo/.github/workflows/ci.yml'
  'ALLOW|Edit|.gitattributes|/repo/.gitattributes'
  'ALLOW|Write|normal source file|/repo/src/main.rs'

  # === Vector 3: bash writes into .git/ — must BLOCK ===
  'BLOCK|Bash|redirect into .git/config|echo "[user]" >> .git/config'
  'BLOCK|Bash|remove a hook|rm .git/hooks/pre-commit'
  'BLOCK|Bash|chmod -x a hook|chmod -x .git/hooks/pre-commit'
  'BLOCK|Bash|sed -i .git/config|sed -i "s/x/y/" .git/config'
  'BLOCK|Bash|tee into .git/config|echo x | tee .git/config'

  # === Vector 3: reads of .git/ — must ALLOW ===
  'ALLOW|Bash|cat .git/config (read)|cat .git/config'
  'ALLOW|Bash|grep in .git/config (read)|grep gpgsign .git/config'
)

pass=0
false_positives=()
false_negatives=()

printf '%-7s %-7s %-7s  %s\n' "DESIRED" "ACTUAL" "TOOL" "CASE"
printf '%-7s %-7s %-7s  %s\n' "-------" "------" "----" "----"

for entry in "${cases[@]}"; do
  desired="${entry%%|*}"; rest="${entry#*|}"
  tool="${rest%%|*}"; rest="${rest#*|}"
  desc="${rest%%|*}"; arg="${rest#*|}"

  if hook_would_block "$tool" "$arg"; then actual="BLOCK"; else actual="ALLOW"; fi

  if [ "$actual" = "$desired" ]; then
    mark="ok"; pass=$((pass + 1))
  elif [ "$desired" = "ALLOW" ]; then
    mark="FALSE POSITIVE"; false_positives+=("[$tool] $desc  ->  $arg")
  else
    mark="FALSE NEGATIVE"; false_negatives+=("[$tool] $desc  ->  $arg")
  fi

  printf '%-7s %-7s %-7s  %s [%s]\n' "$desired" "$actual" "$tool" "$desc" "$mark"
done

total=${#cases[@]}
echo
echo "Passed $pass / $total"

if [ ${#false_positives[@]} -gt 0 ]; then
  echo
  echo "FALSE POSITIVES (rule over-blocks legitimate actions):"
  printf '  - %s\n' "${false_positives[@]}"
fi
if [ ${#false_negatives[@]} -gt 0 ]; then
  echo
  echo "FALSE NEGATIVES (rule lets a real bypass through):"
  printf '  - %s\n' "${false_negatives[@]}"
fi

[ "$pass" -eq "$total" ]
