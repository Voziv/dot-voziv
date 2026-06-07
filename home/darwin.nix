{ username, lib, ... }:
let
  # On macOS the whole system (incl. home-manager) is applied via
  # darwin-rebuild, so `hms` calls that instead of standalone home-manager.
  # The $HOME/.dotfiles symlink is maintained by install.sh; moving this
  # checkout and re-running install.sh refreshes it.
  #
  # `hms` builds first and previews before switching:
  #   - `nvd diff` shows nix store package/version changes.
  #   - `brew bundle cleanup --zap` (dry run) shows what Homebrew will
  #     uninstall, since brew lives outside the nix store and is invisible to
  #     nvd. Anything not in darwin/hosts/<host>.nix gets zapped on switch, so
  #     add what you want to keep before answering yes.
  # Defined as a function (portable across bash + zsh) so it can prompt.
  hmsFunction = ''
    hms() {
      local host
      host="$(hostname -s)"
      darwin-rebuild build --flake "$HOME/.dotfiles#$host" || return
      echo
      echo "── nix store changes ─────────────────────────────"
      nvd diff /run/current-system ./result
      local brewfile
      brewfile="$(grep -o "/nix/store/[^']*Brewfile" ./result/activate 2>/dev/null | head -1)"
      if [ -n "$brewfile" ]; then
        echo
        echo "── homebrew (dry run — what 'zap' will uninstall) ─"
        brew bundle cleanup --zap --file="$brewfile"
      fi
      echo
      printf "Apply these changes? [y/N] "
      read REPLY
      case "$REPLY" in
        [yY]*) sudo darwin-rebuild switch --flake "$HOME/.dotfiles#$host" ;;
        *) echo "Aborted — nothing applied."; rm -f result; return 1 ;;
      esac
      rm -f result
    }
  '';
in
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  programs.zsh.initContent = lib.mkOrder 1500 hmsFunction;
  programs.bash.initExtra = hmsFunction;

  # Append Homebrew paths so brew-installed CLIs are reachable. We do this
  # manually rather than via `eval "$(brew shellenv)"` because current
  # Homebrew invokes /usr/libexec/path_helper which rebuilds PATH from
  # scratch and wipes everything nix-darwin's /etc/zshenv set up
  # (~/.nix-profile/bin, /run/current-system/sw/bin, etc.). Append (not
  # prepend) so nix versions win for tools we manage in both.
  programs.zsh.profileExtra = ''
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
    typeset -U path
    path+=(/opt/homebrew/bin /opt/homebrew/sbin)
    fpath+=(/opt/homebrew/share/zsh/site-functions)
  '';

  programs.bash.profileExtra = ''
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
    case ":$PATH:" in
      *:/opt/homebrew/bin:*) ;;
      *) export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin" ;;
    esac
  '';
}
