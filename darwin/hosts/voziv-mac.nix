{ username, ... }:
{
  # 1Password CLI — installed here (and in home/linux.nix) rather than shared
  # home/packages.nix, since not every machine runs 1Password.
  home-manager.users.${username} = { pkgs, ... }: {
    home.packages = [ pkgs._1password-cli ];
  };

  homebrew = {
    casks = [
      "1password"
      "crystalfetch"
      "discord"
      "firefox"
      "ghostty"
      "jordanbaird-ice"
      "keepingyouawake"
      "linearmouse"
      "notunes"
      "obsidian"
      "orbstack"
      "prismlauncher"
      "vuescan"
      "spotify"
      "utm"
      "warp"
      "zen"
    ];

    brews = [
      "azure-cli"
      "composer"
      "nvm"
      "php"
      "sane-backends"
      "tesseract"
    ];
  };
}
