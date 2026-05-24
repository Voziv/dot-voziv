{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 15000;
      save = 150000;
      path = "$HOME/.histfile";
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
      extended = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" "sudo" "fzf" ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    initContent = lib.mkMerge [
      # Powerlevel10k instant prompt — keep near the top, before any output.
      (lib.mkOrder 200 ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      (lib.mkOrder 1000 ''
      setopt interactivecomments
      setopt BANG_HIST EXTENDED_HISTORY INC_APPEND_HISTORY \
             HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS \
             HIST_FIND_NO_DUPS HIST_IGNORE_SPACE HIST_SAVE_NO_DUPS \
             HIST_REDUCE_BLANKS HIST_VERIFY HIST_BEEP
      unsetopt beep

      DISABLE_AUTO_TITLE="true"

      autoload edit-command-line
      zle -N edit-command-line
      bindkey '^Xe' edit-command-line

      export GPG_TTY=$(tty)

      # Powerlevel10k prompt config (the theme is loaded via programs.zsh.plugins).
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Cross-shell modules (platform detection, paths, aliases, NVM, 1Password SSH agent…)
      if [ -d "$HOME/.voziv/rc.d" ]; then
        for file in "$HOME/.voziv/rc.d"/*.sh; do
          [ -r "$file" ] && . "$file"
        done
      fi

      # Zsh-specific modules (completions, asdf, global aliases, …).
      if [ -d "$HOME/.voziv/zshrc.d" ]; then
        for file in "$HOME/.voziv/zshrc.d"/*.zsh; do
          [ -r "$file" ] && . "$file"
        done
      fi
    '')
    ];
  };
}
