{ config, pkgs, username, ... }:
{
  # Determinate Nix manages the Nix daemon itself, so opt nix-darwin out of
  # managing it. Flakes + nix-command are on by default in Determinate.
  nix.enable = false;
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
      # Use F1/F2/etc. as standard function keys, not media keys.
      "com.apple.keyboard.fnState" = true;
      # Force Click off; swipe-between-pages with scroll off.
      "com.apple.trackpad.forceClick" = false;
      AppleEnableSwipeNavigateWithScrolls = false;
    };

    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 48;
      mru-spaces = false;
      # Bottom-right hot corner disabled (was Quick Note, which is unwanted).
      wvous-br-corner = 1;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    trackpad = {
      Clicking = true;
      Dragging = false;
      DragLock = false;
      TrackpadRightClick = true;
      # Must stay off: macOS silently promotes the Mission Control and
      # app-switch swipes from three fingers to four whenever three-finger
      # drag is enabled, which breaks TrackpadThreeFingerVertSwipeGesture below.
      TrackpadThreeFingerDrag = false;
      TrackpadThreeFingerTapGesture = 0; # look-up tap off
      TrackpadCornerSecondaryClick = 0;
      ActuateDetents = true;
      FirstClickThreshold = 1;
      SecondClickThreshold = 1;
      TrackpadPinch = true; # two-finger zoom
      TrackpadRotate = true;
      TrackpadTwoFingerDoubleTapGesture = true; # smart zoom
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 3; # Notification Center
      TrackpadThreeFingerHorizSwipeGesture = 2;
      TrackpadThreeFingerVertSwipeGesture = 2;
      TrackpadFourFingerHorizSwipeGesture = 2;
      TrackpadFourFingerVertSwipeGesture = 2;
      TrackpadFourFingerPinchGesture = 2;
    };

    ".GlobalPreferences"."com.apple.mouse.scaling" = 1.0;
  };

  system.defaults.CustomUserPreferences = {
    # Free CMD+Shift+M / CMD+Shift+A for app shortcuts by disabling the
    # Terminal Services entries that claim them. Both live under
    # "NSServicesStatus" in the pbs domain.
    "pbs" = {
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
    # Spotlight hotkeys. The IDs are easy to mix up and a wrong one silently
    # kills CMD+Space, so both are pinned explicitly:
    #   64 = Show Spotlight search      (CMD+Space)
    #   65 = Show Finder search window  (CMD+Option+Space)
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        "64" = { enabled = true; };
        "65" = { enabled = false; };
      };
    };

    # Mission Control gestures. Pinned so a macOS update can't flip them back.
    "com.apple.dock" = {
      showMissionControlGestureEnabled = true;
      showAppExposeGestureEnabled = false;
      enterMissionControlByTopWindowDrag = false;
    };

    # Trackpad gesture keys with no typed nix-darwin option. Written to both
    # trackpad domains so wired and Bluetooth trackpads stay in sync.
    "com.apple.AppleMultitouchTrackpad" = {
      TrackpadFiveFingerPinchGesture = 2;
      TrackpadHandResting = 1;
      TrackpadHorizScroll = 1;
      TrackpadScroll = 1;
      USBMouseStopsTrackpad = 0;
    };
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      TrackpadFiveFingerPinchGesture = 2;
      TrackpadHandResting = 1;
      TrackpadHorizScroll = 1;
      TrackpadScroll = 1;
      USBMouseStopsTrackpad = 0;
    };
  };

  # ─── Touch ID for sudo ───────────────────────────────────────────────────
  # Manages /etc/pam.d/sudo_local. `reattach` pulls in pam_reattach so the
  # fingerprint prompt also works when sudo runs inside tmux/screen.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # ─── Homebrew bridge (apps not in nixpkgs) ───────────────────────────────
  # nix-darwin doesn't install Homebrew itself; install it once manually:
  #   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  #
  # Per-host cask/brew/tap lists live in ./hosts/<host>.nix.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # Homebrew 6.x deprecated the bare `--cleanup` flag that nix-darwin emits
      # for cleanup = "zap"/"uninstall". Keep nix-darwin's cleanup off and drive
      # the zap ourselves with the supported `--force-cleanup --zap` flags, so
      # orphan brews are still removed without the deprecation warning. Revisit
      # once nix-darwin moves to the `brew bundle cleanup` subcommand.
      cleanup = "none";
      extraFlags = [ "--force-cleanup" "--zap" ];
    };
  };

  # `brew bundle --upgrade` (the homebrew activation above) only upgrades
  # entries listed in the generated Brewfile — transitive dependencies are
  # installed but never upgraded, so they rot indefinitely. Sweep them up with a
  # real `brew upgrade` afterwards. postActivation is the next activation step
  # after `homebrew`, so the bundle has already installed/zapped by this point.
  #
  # Runs through `sudo --user` like nix-darwin's own bundle invocation: brew
  # refuses to run as root, and activation runs as root. On Workbrew hosts
  # homebrew.prefix points at /opt/workbrew, so this resolves to the wrapper the
  # forced-wrapper policy demands (see darwin/hosts/lrobert-rh.nix).
  system.activationScripts.postActivation.text = ''
    echo >&2 "Homebrew upgrade..."
    if [ -f "${config.homebrew.prefix}/bin/brew" ]; then
      sudo \
        --user=${username} \
        --set-home \
        "${config.homebrew.prefix}/bin/brew" upgrade
    fi
  '';

  # Battery toolkit comes from a tap and requires --no-quarantine. Add
  # manually after the first switch:
  #   brew install mhaeuser/mhaeuser/battery-toolkit --no-quarantine
  #
  # Docker plugin path config (matches the snippet in MAC.md). This lands
  # in $HOME via home-manager so it tracks with user state.
  # See home/default.nix → ".docker/config.json" if you'd rather declare it there.

  # Use zsh as the default shell. nix-darwin wires this in to /etc/shells too.
  programs.zsh.enable = true;
  # nix-darwin's global compinit (in /etc/zshrc) runs before our zshrc.d files
  # and without -u, so on the Workbrew-managed mac it prompts about the
  # group-writable /opt/homebrew/share/zsh dirs before our `compinit -u` in
  # src/.voziv/zshrc.d/06-completions.zsh can run. Disable it and let that file
  # own compinit; enableCompletion stays on so the nix completion fpath is kept.
  programs.zsh.enableGlobalCompInit = false;

  # Symlink nix-installed GUI apps into ~/Applications/Nix Apps.
  system.activationScripts.applications.text = ''
    echo "setting up ~/Applications/Nix Apps..." >&2
    rm -rf "$HOME/Applications/Nix Apps"
    mkdir -p "$HOME/Applications/Nix Apps"
    find "$HOME/.nix-profile/Applications" -maxdepth 1 -type l \
      -exec ln -s {} "$HOME/Applications/Nix Apps/" \; 2>/dev/null || true
  '';
}
