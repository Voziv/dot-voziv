{ pkgs, username, ... }:
{
  # Identify yourself to nix.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = 5;

  # nix-darwin needs to know who the primary user is for some defaults.
  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  # ─── macOS system defaults ───────────────────────────────────────────────
  # These replace the manual checklist at the top of MAC.md.
  system.defaults = {
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      AppleShowAllExtensions = true;
      AppleInterfaceStyle = "Dark";
    };

    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 48;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    # Disable the system services that bind to CMD+Shift+M / CMD+Shift+A,
    # so JetBrains tools can use them. Equivalent to the three "unbind"
    # steps in MAC.md.
    #
    # NSUserKeyEquivalents disables the relevant menu shortcuts globally.
    ".GlobalPreferences"."com.apple.mouse.scaling" = 1.0;
  };

  # Disable specific keyboard shortcuts (Service menu entries) by setting
  # NSUserKeyEquivalents on the host app. These are the closest declarative
  # equivalent to the manual unbind steps in MAC.md.
  system.defaults.CustomUserPreferences = {
    "pbs" = {
      # Open Man Page in Terminal (CMD+Shift+M) and Search Man Page Index
      # in Terminal (CMD+Shift+A) live under "NSServicesStatus".
      "NSServicesStatus" = {
        "com.apple.Terminal - Open man Page in Terminal - openManPage" = {
          enabled_context_menu = false;
          enabled_services_menu = false;
          presentation_modes = {
            ContextMenu = false;
            ServicesMenu = false;
          };
        };
        "com.apple.Terminal - Search man Page Index in Terminal - searchManPages" = {
          enabled_context_menu = false;
          enabled_services_menu = false;
          presentation_modes = {
            ContextMenu = false;
            ServicesMenu = false;
          };
        };
      };
    };
    # Disable Spotlight's "Show Finder search window" (CMD+Shift+A) by
    # clearing its key equivalent.
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys."64" = { enabled = false; };
    };
  };

  # ─── Homebrew bridge (apps not in nixpkgs) ───────────────────────────────
  # nix-darwin doesn't install Homebrew itself; install it once manually:
  #   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    casks = [
      "1password"
      "1password-cli"
      "discord"
      "jetbrains-toolbox"
      "logi-options+"
      "magic-switch"
      "spotify"
      "todoist"
      "zen-browser"
    ];

    brews = [
      "colima"
      "docker"
      "docker-compose"
      "docker-buildx"
      "composer"
      "nvm"
    ];

    taps = [
      "mhaeuser/mhaeuser"
    ];
  };

  # Battery toolkit comes from a tap and requires --no-quarantine. Add
  # manually after the first switch:
  #   brew install mhaeuser/mhaeuser/battery-toolkit --no-quarantine
  #
  # Docker plugin path config (matches the snippet in MAC.md). This lands
  # in $HOME via home-manager so it tracks with user state.
  # See home/default.nix → ".docker/config.json" if you'd rather declare it there.

  # Use zsh as the default shell. nix-darwin wires this in to /etc/shells too.
  programs.zsh.enable = true;

  # Symlink nix-installed GUI apps into ~/Applications/Nix Apps.
  system.activationScripts.applications.text = ''
    echo "setting up ~/Applications/Nix Apps..." >&2
    rm -rf "$HOME/Applications/Nix Apps"
    mkdir -p "$HOME/Applications/Nix Apps"
    for app in $(find $HOME/.nix-profile/Applications -maxdepth 1 -type l 2>/dev/null); do
      ln -s "$app" "$HOME/Applications/Nix Apps/"
    done
  '';
}
