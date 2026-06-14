{ username, lib, ... }:
let
  # On macOS the whole system (incl. home-manager) is applied via
  # darwin-rebuild, so `hms` calls that instead of standalone home-manager.
  # The $HOME/.dotfiles symlink is maintained by install.sh; moving this
  # checkout and re-running install.sh refreshes it.
  #
  # `hms` builds first, shows an `nvd diff` of nix store package/version
  # changes, then applies directly. Homebrew lives outside the nix store and
  # isn't previewed here; anything not in darwin/hosts/<host>.nix gets zapped
  # on switch.
  # Defined as a function (portable across bash + zsh).
  hmsFunction = ''
    hms() {
      local host
      host="$(hostname -s)"
      darwin-rebuild build --flake "$HOME/.dotfiles#$host" || return
      echo
      echo "── nix store changes ─────────────────────────────"
      nvd diff /run/current-system ./result
      echo
      sudo darwin-rebuild switch --flake "$HOME/.dotfiles#$host"
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
