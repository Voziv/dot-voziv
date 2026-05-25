---
paths:
  - "**/*.sh"
  - "**/*.zsh"
  - "**/*.bash"
---

# Shell scripting conventions

- Prefer `rg` over `grep` and `fd` over `find`.
- Quote all variable expansions (`"$var"`) unless word-splitting is intended.
- Use `set -euo pipefail` at the top of non-interactive scripts.
- Keep interactive shell config (rc.d, zshrc.d) idempotent — sourcing twice must
  not break the shell.
