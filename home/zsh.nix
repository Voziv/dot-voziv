{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # Switch this machine's home-manager generation. Selects the flake config
      # matching `hostname -s` (voziv-pc / voziv-mac / lrobert-rh).
      hms = ''home-manager switch --flake "$HOME/dev/dot-voziv#$(hostname -s)"'';
    };

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

    initContent = lib.mkOrder 1000 ''
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
      export EDITOR=nvim

      # Pure prompt — installed from nixpkgs, no submodule required.
      fpath+=("${pkgs.pure-prompt}/share/zsh/site-functions")
      autoload -U promptinit
      promptinit
      prompt pure
      PURE_GIT_PULL=0

      # Cross-shell modules (platform detection, paths, aliases, NVM, 1Password SSH agent…)
      if [ -d "$HOME/.voziv/rc.d" ]; then
        for file in "$HOME/.voziv/rc.d"/*.sh; do
          [ -r "$file" ] && . "$file"
        done
      fi

      # Zsh-specific modules. Files migrated to native nix modules
      # (01-zshrc.zsh, 02-oh-my.zsh, 02-pure.zsh) are explicitly skipped.
      if [ -d "$HOME/.voziv/zshrc.d" ]; then
        for file in "$HOME/.voziv/zshrc.d"/*.zsh; do
          case "$(basename "$file")" in
            01-zshrc.zsh|02-oh-my.zsh|02-pure.zsh) continue ;;
          esac
          [ -r "$file" ] && . "$file"
        done
      fi
    '';
  };
}
