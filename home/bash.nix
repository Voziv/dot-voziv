{ ... }:
{
  programs.bash = {
    enable = true;

    historyControl = [ "ignoredups" "ignorespace" ];
    historyFileSize = 150000;
    historySize = 15000;

    # Source the same cross-shell modules zsh loads (platform detection, paths,
    # aliases, NVM, 1Password SSH agent…). The zsh-only modules under zshrc.d
    # are intentionally not sourced here.
    initExtra = ''
      if [ -d "$HOME/.voziv/rc.d" ]; then
        for file in "$HOME/.voziv/rc.d"/*.sh; do
          [ -r "$file" ] && . "$file"
        done
      fi
    '';
  };
}
