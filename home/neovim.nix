{ pkgs, self, ... }:
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;

    viAlias = false;
    vimAlias = false;

    # No plugin here needs the Ruby or Python 3 remote-plugin providers, so
    # skip them (also the new home-manager default at stateVersion >= 26.05).
    withRuby = false;
    withPython3 = false;

    # Existing init.lua bootstraps lazy.nvim, which manages its own plugins
    # at runtime. Declarative nix plugin management is a possible future step;
    # for now we let lazy own that.
    initLua = builtins.readFile "${self}/src/.voziv/nvim/init.lua";
  };

  # Lazy.nvim writes the lockfile next to init.lua. We keep init.lua read-only
  # via the nix store, so let lazy work out of ~/.config/nvim instead.
  # (programs.neovim above already installs init.lua at ~/.config/nvim/init.lua.)
}
