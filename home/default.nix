{ self, ... }:
{
  imports = [
    ./packages.nix
    ./zsh.nix
    ./git.nix
    ./tmux.nix
    ./neovim.nix
    ./secrets.nix
  ];

  programs.home-manager.enable = true;

  # Pick the release matching your nixpkgs branch; never bump after first switch.
  home.stateVersion = "24.11";

  # Mirror src/.voziv tree into ~/.voziv (the stow equivalent).
  # recursive = true → individual file symlinks, so the directory stays writable
  # (needed for voziv-sync-secrets to drop rendered files alongside templates).
  home.file = {
    ".voziv/bin"     = { source = "${self}/src/.voziv/bin";     recursive = true; };
    ".voziv/rc.d"    = { source = "${self}/src/.voziv/rc.d";    recursive = true; };
    ".voziv/zshrc.d" = { source = "${self}/src/.voziv/zshrc.d"; recursive = true; };
    ".voziv/envs"    = { source = "${self}/src/.voziv/envs";    recursive = true; };
    ".voziv/openssl" = { source = "${self}/src/.voziv/openssl"; recursive = true; };
    ".voziv/profile".source = "${self}/src/.voziv/profile";

    ".screenrc".source = "${self}/src/.screenrc";

    # gitignore_global is referenced by programs.git.settings.core.excludesfile.
    ".gitignore_global".source = "${self}/src/.gitignore_global";

    # SSH config template — rendered by voziv-sync-secrets from 1Password.
    ".voziv/ssh/voziv_config.tpl".source = "${self}/src/.voziv/ssh/voziv_config.tpl";
  };
}
