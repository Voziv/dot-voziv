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
in
{
  programs.claude-code = {
    enable = true;

    # claude-code is installed outside Nix; home-manager owns the config only,
    # never the binary. (enable + package = null manages files without an
    # install; assertions only fire for MCP/LSP/plugin features, unused here.)
    package = null;

    # Generated to ~/.claude/settings.json. This becomes a read-only store
    # symlink, so interactive /config or theme edits won't persist — change them
    # here and `hms` instead.
    settings = {
      theme = "dark";
      skipAutoPermissionPrompt = true;
      attribution = {
        commit = "";
        pr = "";
      };
      permissions.defaultMode = "auto";
      statusLine = {
        type = "command";
        command = "bash ${claudeDir}/statusline-command.sh";
        padding = 1;
      };

      # Official plugins, enabled declaratively. We can't use the module's
      # `plugins` option here because it wraps the claude-code binary and asserts
      # `package != null`, but this host installs the binary outside Nix. Instead
      # we flip them on via settings; the `claude-plugins-official` marketplace is
      # auto-installed by Claude Code on first run.
      enabledPlugins =
        lib.genAttrs
          (map (plugin: "${plugin}@claude-plugins-official") [
            "frontend-design"
            "superpowers"
            "code-review"
            "code-simplifier"
            "feature-dev"
            "pr-review-toolkit"
          ])
          (_: true);
    };

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
