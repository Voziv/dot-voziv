{ self, ... }:
{
  imports = [
    ./packages.nix
    ./bash.nix
    ./zsh.nix
    ./ssh.nix
    ./git.nix
    ./tmux.nix
    ./neovim.nix
    ./claude.nix
  ];

  programs.home-manager.enable = true;

  # Pick the release matching your nixpkgs branch; never bump after first switch.
  home.stateVersion = "24.11";

  # Shared across bash and zsh.
  home.sessionVariables = {
    EDITOR = "nvim";
    TZ = "America/Toronto";
  };

  home.shellAliases = {
    # Switch this machine's home-manager generation. Selects the flake config
    # matching `hostname -s` (voziv-pc / voziv-mac / lrobert-rh).
    hms = ''home-manager switch --flake "$HOME/dev/dot-voziv#$(hostname -s)"'';

    grep = "grep --color=auto";
  };

  # Mirror the src/.voziv tree into ~/.voziv (the stow equivalent).
  # recursive = true → individual file symlinks, so the directory stays writable.
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

    # Powerlevel10k prompt config (sourced from home/zsh.nix). Managed here so
    # the prompt is identical on every machine; `p10k configure` can't rewrite
    # it while it's a store symlink — edit src/.p10k.zsh and switch instead.
    ".p10k.zsh".source = "${self}/src/.p10k.zsh";
  };
}
