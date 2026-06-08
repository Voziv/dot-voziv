{ username, lib, pkgs, ... }:
let
  # Linux uses standalone home-manager (no nix-darwin equivalent, no brew).
  # The $HOME/.dotfiles symlink is maintained by install.sh; moving this
  # checkout and re-running install.sh refreshes it.
  #
  # `hms` builds first and shows an `nvd diff` of nix store package/version
  # changes against the current generation, then prompts before switching.
  # Defined as a function (portable across bash + zsh) so it can prompt.
  hmsFunction = ''
    hms() {
      local host current
      host="$(hostname -s)"
      home-manager build --flake "$HOME/.dotfiles#$host" || return
      current="''${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager"
      echo
      echo "── changes ───────────────────────────────────────"
      if [ -e "$current" ]; then
        nvd diff "$current" ./result
      else
        echo "(no current generation found; skipping diff)"
      fi
      echo
      printf "Apply these changes? [y/N] "
      read REPLY
      case "$REPLY" in
        [yY]*) home-manager switch --flake "$HOME/.dotfiles#$host" ;;
        *) echo "Aborted — nothing applied."; rm -f result; return 1 ;;
      esac
      rm -f result
    }
  '';
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # 1Password CLI — installed here (and in darwin/hosts/voziv-mac.nix) rather
  # than shared home/packages.nix, since not every machine runs 1Password.
  home.packages = [ pkgs._1password-cli ];

  programs.zsh.initContent = lib.mkOrder 1500 hmsFunction;
  programs.bash.initExtra = hmsFunction;
}
