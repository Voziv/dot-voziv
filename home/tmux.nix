{ ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    mouse = true;
    baseIndex = 1;
    historyLimit = 1000;
    terminal = "screen-256color";
    escapeTime = 10;

    # GNU-screen-style keybindings + a few personal additions.
    extraConfig = ''
      # send-prefix on second C-a (already bound by `prefix = "C-a"`).
      bind a send-prefix

      # lockscreen ^X x
      unbind ^X
      bind   ^X lock-server
      unbind  x
      bind    x lock-server

      # new window ^C c
      unbind ^C
      bind   ^C new-window
      unbind  c
      bind    c new-window -c "#{pane_current_path}"

      # detach ^D d
      unbind ^D
      bind   ^D detach

      # list clients *
      unbind *
      bind   * list-clients

      # next window ^@ ^N space n
      unbind ^@
      bind   ^@ next-window
      unbind ^N
      bind   ^N next-window
      unbind " "
      bind   " " next-window
      unbind  n
      bind    n next-window

      # rename window A
      unbind A
      bind   A command-prompt "rename-window %%"

      # last window ^A
      unbind ^A
      bind   ^A last-window

      # prev window ^H ^P p backspace
      unbind ^H
      bind   ^H previous-window
      unbind ^P
      bind   ^P previous-window
      unbind  p
      bind    p previous-window
      unbind BSpace
      bind   BSpace previous-window

      # list windows ^W w
      unbind ^W
      bind   ^W list-windows
      unbind  w
      bind    w list-windows

      # kill server \
      unbind \\
      bind   \\ confirm-before "kill-server"

      # kill window K k
      unbind K
      bind   K confirm-before "kill-window"
      unbind k
      bind   k confirm-before "kill-window"

      # redisplay ^L l
      unbind ^L
      bind   ^L refresh-client
      unbind  l
      bind    l refresh-client

      # splits — preserve cwd
      unbind %
      bind   | split-window -h -c "#{pane_current_path}"
      bind   v split-window -h -c "#{pane_current_path}"
      unbind '"'
      bind   - split-window -v -c "#{pane_current_path}"
      bind   h split-window -v -c "#{pane_current_path}"

      # pane navigation
      unbind o
      bind   C-s select-pane -t :.-
      unbind Tab
      bind   Tab select-pane -t :.+
      unbind BTab
      bind   BTab select-pane -t :.-

      # window list overlay
      unbind '"'
      bind   '"' choose-window

      # window title
      set -g set-titles on
      set -g set-titles-string '#S:#I.#P #W'

      # status bar
      set -g status-bg black
      set -g status-fg white
      set -g status-interval 1
      set -g status-left '#[fg=green]#H#[default]'

      # clock
      setw -g clock-mode-colour green
      setw -g clock-mode-style 24
    '';
  };
}
