{ ... }:
{
  # Zed config for the two macs (imported from home/darwin.nix). Zed itself is
  # installed outside Nix (manual /Applications/Zed.app), so package = null:
  # home-manager owns the config only, never the binary.
  programs.zed-editor = {
    enable = true;
    package = null;

    # settings.json stays a writable file; on each switch home-manager deep-merges
    # the keys below over whatever Zed has written, so in-app setting changes for
    # unmanaged keys persist. keymap.json is written verbatim (read-only) because
    # the mutable merge groups entries by context and would collapse the ordered
    # bindings/unbind pairs below into one ambiguous object per context.
    mutableUserSettings = true;
    mutableUserKeymaps = false;

    userSettings = {
      # Place `claude --worktree` worktrees where Zed's worktree switcher looks,
      # matching the WorktreeCreate hook in home/claude.nix.
      git.worktree_directory = "~/.worktrees";

      indent_guides = {
        active_line_width = 3;
        line_width = 1;
        background_coloring = "disabled";
      };
      format_on_save = "on";
      edit_predictions.allow_data_collection = "no";
      autosave = "on_focus_change";
      vim_mode = false;
      project_panel.dock = "left";
      outline_panel.dock = "left";
      collaboration_panel.dock = "left";
      # favorite_models / model_parameters are intentionally not managed here:
      # Zed writes them at runtime, and declaring them would reset on every switch.
      agent = {
        sidebar_side = "right";
        dock = "right";
      };
      git_panel.dock = "left";
      icon_theme = {
        mode = "light";
        light = "Catppuccin Latte";
        dark = "Catppuccin Mocha";
      };
      use_system_window_tabs = true;
      tab_bar.show = false;
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      agent_servers = {
        "github-copilot-cli".type = "registry";
        "claude-acp".type = "registry";
      };
      base_keymap = "JetBrains";
      ui_font_size = 16;
      buffer_font_size = 16.0;
      theme = {
        mode = "system";
        light = "One Light";
        dark = "One Dark";
      };
      languages = {
        JavaScript = {
          tab_size = 4;
          code_actions_on_format."source.fixAll.eslint" = true;
        };
        TypeScript = {
          tab_size = 4;
          code_actions_on_format."source.fixAll.eslint" = true;
          language_servers = [ "typescript-language-server" "!vtsls" ];
        };
        TSX = {
          tab_size = 4;
          code_actions_on_format."source.fixAll.eslint" = true;
          language_servers = [ "typescript-language-server" "!vtsls" ];
        };
      };
    };

    userKeymaps = [
      { context = "Workspace"; bindings = { "cmd-o" = [ "projects::OpenRecent" { create_new_window = false; } ]; }; }
      { context = "Workspace"; unbind   = { "ctrl-r" = [ "projects::OpenRecent" { create_new_window = false; } ]; }; }
      { context = "Workspace || Editor"; bindings = { "cmd-f12" = "terminal_panel::Toggle"; }; }
      { context = "Workspace || Editor"; unbind   = { "alt-f12" = "terminal_panel::Toggle"; }; }
      { bindings = { "ctrl-cmd-shift-o" = "workspace::Open"; }; }
      { unbind   = { "cmd-o" = "workspace::Open"; }; }
      { context = "Editor && multibuffer"; unbind = { "cmd-shift-up"   = "editor::SelectToStartOfExcerpt"; }; }
      { context = "Editor";                unbind = { "cmd-shift-up"   = "editor::SelectToBeginning"; }; }
      { context = "Editor";                unbind = { "cmd-shift-down" = "editor::SelectToEnd"; }; }
      { context = "Editor && multibuffer"; unbind = { "cmd-shift-down" = "editor::SelectToStartOfNextExcerpt"; }; }
      { context = "Editor"; unbind   = { "alt-shift-up"   = "editor::MoveLineUp"; }; }
      { context = "Editor"; bindings = { "cmd-shift-up"   = "editor::MoveLineUp"; }; }
      { context = "Editor"; unbind   = { "alt-up"         = "editor::MoveLineUp"; }; }
      { context = "Editor"; bindings = { "cmd-shift-down" = "editor::MoveLineDown"; }; }
      { context = "Editor"; unbind   = { "alt-shift-down" = "editor::MoveLineDown"; }; }
      { context = "Editor"; bindings = { "cmd-shift-l"    = "editor::Format"; }; }
      { context = "Editor"; unbind   = { "alt-cmd-l"      = "editor::Format"; }; }
      { context = "Editor"; bindings = { "shift-delete"   = "editor::DeleteLine"; }; }
    ];
  };
}
