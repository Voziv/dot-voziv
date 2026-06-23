{ config, lib, pkgs, self, ... }:
let
  claudeDir = "${config.home.homeDirectory}/.claude";

  # The three hosts are uniquely identified by (username, OS):
  #   voziv-pc   = voziv      + Linux
  #   voziv-mac  = voziv      + Darwin
  #   lrobert-rh = lee.robert + Darwin
  hostKey =
    if config.home.username == "lee.robert" then "lrobert-rh"
    else if pkgs.stdenv.hostPlatform.isDarwin then "voziv-mac"
    else "voziv-pc";

  # Optional per-machine instructions appended to the shared CLAUDE.md. Drop a
  # src/.claude/hosts/<hostKey>.md file to add a machine-specific tail; absent
  # files contribute nothing.
  hostContextFile = "${self}/src/.claude/hosts/${hostKey}.md";
  perHostContext =
    lib.optionalString (builtins.pathExists hostContextFile)
      ("\n" + builtins.readFile hostContextFile);

  mkEnabledPlugins = plugins:
    lib.genAttrs (map (plugin: "${plugin}@claude-plugins-official") plugins) (_: true);

  # Stops agents from bypassing or weakening the git-side signing/verification
  # policy. PreToolUse runs before the call, so this is a guard against bypass
  # attempts, not proof of signing (signByDefault in git.nix is what proves
  # that). The matcher logic lives in a committed script so it can be unit-tested
  # directly by test-git-policy-hook.sh at the repo root; this wrapper only pins
  # the tools it needs on PATH and hands off. It covers: git commit bypass flags,
  # git config writes, inline `git -c`/`--config-env` overrides, and direct edits
  # to files under any .git directory (via tools or bash writes).
  blockGitPolicy = pkgs.writeShellScript "voziv-claude-block-git-policy" ''
    export PATH="${lib.makeBinPath [ pkgs.coreutils pkgs.gnugrep pkgs.gnused pkgs.gawk pkgs.jq ]}:$PATH"
    exec ${pkgs.bash}/bin/bash ${self}/src/.claude/hooks/block-git-policy.sh
  '';

  # WorktreeCreate hook: place `claude --worktree` worktrees under a predictable
  # ~/.worktrees/<repo>/<name> tree (shared with editors that read the same
  # directory, e.g. Zed's worktree switcher) instead of the default location.
  # Reads Claude's JSON payload from stdin, writes the absolute path to stdout.
  worktreeCreate = pkgs.writeShellScript "voziv-claude-worktree-create" ''
    payload="$(cat)"
    name="$(${pkgs.jq}/bin/jq -r '.name' <<<"$payload")"
    repo="$(basename "$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null)")"
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
    if ${pkgs.git}/bin/git show-ref --verify --quiet "refs/heads/$name"; then
      ${pkgs.git}/bin/git worktree add "$target" "$name" >&2
    else
      ${pkgs.git}/bin/git worktree add "$target" -b "$name" >&2
    fi
    echo "$target"
  '';

  # WorktreeRemove hook: safely tear down a worktree on removal, but refuse if it
  # has uncommitted changes so in-progress work is never silently lost.
  worktreeRemove = pkgs.writeShellScript "voziv-claude-worktree-remove" ''
    payload="$(cat)"
    path="$(${pkgs.jq}/bin/jq -r '.worktree_path' <<<"$payload")"
    if [ -z "$path" ] || [ "$path" = null ] || [ ! -d "$path" ]; then
      exit 0
    fi
    cd "$path" || exit 1
    if ! ${pkgs.git}/bin/git diff-index --quiet HEAD --; then
      echo "Warning: uncommitted changes in $path. Skipping auto-removal." >&2
      exit 0
    fi
    cd "$HOME" || exit 1
    ${pkgs.git}/bin/git worktree remove "$path" >&2
  '';

  # Shared settings → ~/.claude/settings.json on every machine.
  baseSettings = {
    theme = "dark";
    skipAutoPermissionPrompt = true;
    voice = {
      enabled = true;
      mode = "hold";
      autoSubmit = true;
    };
    attribution = {
      commit = "";
      pr = "";
    };
    permissions.defaultMode = "auto";
    env = {
      CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
    };
    statusLine = {
      type = "command";
      command = "bash ${claudeDir}/statusline-command.sh";
      padding = 1;
    };
    enabledPlugins = mkEnabledPlugins [
      "frontend-design"
      "superpowers"
      "code-review"
      "code-simplifier"
      "feature-dev"
      "pr-review-toolkit"
    ];
    # Branch name == worktree name (no auto-prefix), so ~/.worktrees/<repo>/<name>
    # and the branch line up with what the WorktreeCreate hook builds.
    worktreeBranchPrefix = "";
    hooks = {
      PreToolUse = [
        {
          matcher = "Bash|Write|Edit|MultiEdit|NotebookEdit";
          hooks = [
            {
              type = "command";
              command = "${blockGitPolicy}";
            }
          ];
        }
      ];
      WorktreeCreate = [
        { hooks = [ { type = "command"; command = "${worktreeCreate}"; } ]; }
      ];
      WorktreeRemove = [
        { hooks = [ { type = "command"; command = "${worktreeRemove}"; } ]; }
      ];
    };
  };

  # Per-machine settings, deep-merged over baseSettings (lib.recursiveUpdate):
  # nested attrsets merge — so a host's enabledPlugins ADD to the shared set —
  # while scalars like `theme` override. Give a machine its own slice by adding
  # a hostKey entry; absent hosts inherit baseSettings unchanged.
  perHostSettings = {
    lrobert-rh = {
      # Ratehub work laptop: auto theme and the extra plugins used for work.
      theme = "auto";
      enabledPlugins = mkEnabledPlugins [
        "zapier"
        "typescript-lsp"
        "cloudflare"
        "datadog"
        "slack"
      ];
    };
  };
in
{
  programs.claude-code = {
    enable = true;

    # claude-code is installed outside Nix; home-manager owns the config only,
    # never the binary. (enable + package = null manages files without an
    # install; assertions only fire for MCP/LSP/plugin features, unused here.)
    package = null;

    # Generated to ~/.claude/settings.json (baseSettings + this machine's
    # overrides). This becomes a read-only store symlink, so interactive
    # /config or theme edits won't persist — change baseSettings/perHostSettings
    # above and `hms` instead.
    #
    # Plugins are enabled via settings.enabledPlugins rather than the module's
    # `plugins` option, which wraps the claude-code binary and asserts
    # `package != null` (this host installs the binary outside Nix). The
    # `claude-plugins-official` marketplace is auto-installed on first run.
    settings = lib.recursiveUpdate baseSettings (perHostSettings.${hostKey} or {});

    # ~/.claude/CLAUDE.md = shared instructions + this machine's tail.
    context = builtins.readFile "${self}/src/.claude/CLAUDE.md" + perHostContext;

    # ~/.claude/rules/*.md — modular, always-loaded user instructions. Files with
    # `paths:` frontmatter load only when Claude touches matching files.
    rulesDir = "${self}/src/.claude/rules";
  };

  # Static script referenced by settings.statusLine above, placed at a stable
  # path so the command resolves regardless of the (differing) home directory.
  home.file.".claude/statusline-command.sh".source =
    "${self}/src/.claude/statusline-command.sh";
}
