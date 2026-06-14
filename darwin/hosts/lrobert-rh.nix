{ username, ... }:
{
  homebrew = {
    taps = [
      "boltops-tools/software"
    ];

    casks = [
      "gcloud-cli"
      "ghostpepper"
      "ghostty"
      "jordanbaird-ice"
      "kdiff3"
      "keepingyouawake"
      "linearmouse"
      "notunes"
      "wispr-flow"
      "boltops-tools/software/terraspace"
    ];

    # cleanup = "zap" (darwin/default.nix) uninstalls any brew not listed here.
    # These mirror `brew list --installed-on-request`, minus tools nix now
    # provides (fd, fzf, gh, go, ripgrep, tree, yq, asdf, argocd, helm,
    # kubectl, neovim) and ruby@3.3 (managed via asdf instead).
    brews = [
      "actionlint"
      "aiven-client"
      "autoconf"
      "automake"
      "awscli"
      "bash"
      "cloud-sql-proxy"
      "colima"
      "composer"
      "coreutils"
      "docker"
      "docker-buildx"
      "docker-compose"
      "excalidraw-converter"
      "ffmpeg"
      "libksba"
      "libyaml"
      "nvm"
      "openjdk"
      "openssl@1.1"
      "pcre2"
      "php"
      "php@8.2"
      "php@8.3"
      "pkgconf"
      "postgresql@14"
      "python@3.12"
      "sops"
      "stow"
      "terraform"
      "uv"
      "wget"
      "zlib"
    ];
  };

  # Machine-specific home-manager config for this work mac. Merges with the
  # shared ./home modules the flake imports for this user.
  home-manager.users.${username} = { config, lib, ... }: {
    # Homebrew 6.x refuses to load casks from third-party taps unless trusted
    # (HOMEBREW_REQUIRE_TAP_TRUST). nix-darwin's homebrew module has no trust
    # option, so declare brew's trust file ourselves to keep the terraspace
    # cask (boltops-tools/software, see casks above) loadable on every switch.
    # Path is ~/.homebrew/trust.json because XDG_CONFIG_HOME is unset here; brew
    # would otherwise read $XDG_CONFIG_HOME/homebrew/trust.json.
    home.file.".homebrew/trust.json".text = builtins.toJSON {
      trustedcasks = [ "boltops-tools/software/terraspace" ];
    };

    # Tool paths that were auto-appended to ~/.zshrc/.bashrc under stow. Under
    # nix the generated rc files are read-only, so declare them here. Ruby is
    # managed by asdf (see src/.voziv/zshrc.d/05-asdf.zsh), so no brew ruby path.
    home.sessionPath = [
      "${config.home.homeDirectory}/.cargo/bin"
      "/opt/homebrew/opt/python@3.12/libexec/bin"
    ];

    # Work identity for this machine. home/git.nix hardcodes the repo owner's
    # personal identity and 1Password signing; override here to match the old
    # ~/.voziv/git/gitconfig.private — sign with this machine's own ed25519 key
    # via ssh-keygen, not the op-ssh-sign wrapper.
    programs.git.signing = {
      key    = lib.mkForce "${config.home.homeDirectory}/.ssh/id_ed25519";
      signer = lib.mkForce "ssh-keygen";
    };
    programs.git.settings.user = {
      name  = lib.mkForce "Lee Robert";
      email = lib.mkForce "267151706+lrobert-ratehub@users.noreply.github.com";
    };

    # home/ssh.nix points IdentityAgent at the 1Password agent socket, which
    # isn't installed on this machine. Fall back to the default agent from
    # $SSH_AUTH_SOCK (the macOS launchd ssh-agent) so ssh still works.
    programs.ssh.settings."*" = lib.mkForce (lib.hm.dag.entryAfter [ "voziv-*" ] {
      IdentityAgent = "SSH_AUTH_SOCK";
      SetEnv = { TERM = "xterm-256color"; };
    });

    # colima writes ~/.colima/ssh_config (Host colima …) for `ssh colima` and
    # colima/docker SSH workflows. This Include was in the pre-nix ~/.ssh/config;
    # ssh ignores it if the file is absent (colima not started).
    programs.ssh.includes = [ "${config.home.homeDirectory}/.colima/ssh_config" ];
  };
}
