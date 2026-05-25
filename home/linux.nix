{ username, ... }:
{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Linux uses standalone home-manager (no nix-darwin equivalent).
  # The $HOME/.dotfiles symlink is maintained by install.sh; moving this
  # checkout and re-running install.sh refreshes it.
  home.shellAliases.hms = ''home-manager switch --flake "$HOME/.dotfiles#$(hostname -s)"'';
}
