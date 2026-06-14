{ username, ... }:
{
  # 1Password CLI — installed here (and in home/linux.nix) rather than shared
  # home/packages.nix, since not every machine runs 1Password.
  home-manager.users.${username} = { pkgs, ... }: {
    home.packages = [ pkgs._1password-cli ];
  };

  homebrew = {
    taps = [
      "coleam00/archon"
    ];

    casks = [
      "1password"
      "astro-editor"
      "discord"
      "ghostty"
      "jetbrains-toolbox"
      "jordanbaird-ice"
      "keepingyouawake"
      "linearmouse"
      "notunes"
      "orbstack"
      "spotify"
      "todoist-app"
      "wispr-flow"
      "zen"
    ];

    brews = [
      "composer"
      "nvm"
      "coleam00/archon/archon"
    ];
  };
}
