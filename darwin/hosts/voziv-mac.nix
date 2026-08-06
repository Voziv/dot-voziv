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
      "affinity"
      "cmux"
      "crystalfetch"
      "discord"
      "jordanbaird-ice"
      "keepingyouawake"
      "linearmouse"
      "notunes"
      "obsidian"
      "orbstack"
      "prismlauncher"
      "vuescan"
      "spotify"
      "todoist-app"
      "utm"
      "zen"
    ];

    brews = [
      "composer"
      "ipp-usb"
      "nvm"
      "php"
      "sane-backends"
      "tesseract"
    ];
  };
}
