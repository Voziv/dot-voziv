{ username, ... }:
{
  homebrew = {
    # This machine is managed by Workbrew. /etc/homebrew/brew.env sets
    # HOMEBREW_FORCE_BREW_WRAPPER=/opt/workbrew/bin/brew and
    # HOMEBREW_DISABLE_NO_FORCE_BREW_WRAPPER=1, so Homebrew refuses any brew run
    # whose parent process isn't the Workbrew wrapper — and that policy can't be
    # overridden from the environment (the system brew.env reloads last). The
    # default activation invokes /opt/homebrew/bin/brew under sudo, tripping the
    # "conflicting Homebrew wrapper configuration" error. Pointing the prefix at
    # the Workbrew bin dir makes nix-darwin run `brew bundle` through the wrapper,
    # which re-execs the real brew so the parent-process check passes. nix-darwin
    # only uses prefix to locate the brew binary and build PATH; the wrapper sets
    # the true HOMEBREW_PREFIX (/opt/homebrew) itself.
    prefix = "/opt/workbrew";

    casks = [
      "cmux"
      "gcloud-cli"
      "ghostpepper"
      "ghostty"
      "jordanbaird-ice"
      "kdiff3"
      "keepingyouawake"
      "linearmouse"
      "notunes"
      "obsidian"
      { name = "boltops-tools/software/terraspace"; trusted = true; }
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

  # Homebrew 6.x refuses to load casks from third-party taps unless the tap is
  # trusted (brew reads ~/.homebrew/trust.json under HOMEBREW_REQUIRE_TAP_TRUST,
  # since XDG_CONFIG_HOME is unset here). nix-darwin's homebrew module has no
  # trust option, and the activation runs `brew bundle` (line "Homebrew
  # bundle...") *before* home-manager links any files — so a home.file trust.json
  # is always too late and the bundle aborts on the boltops terraspace cask.
  # Write the trust file in preActivation, which runs before the bundle step.
  system.activationScripts.preActivation.text = ''
    install -d -o ${username} -g staff -m 0755 "/Users/${username}/.homebrew"
    printf '%s\n' '{"trustedtaps":["boltops-tools/software"],"trustedcasks":["boltops-tools/software/terraspace"]}' \
      > "/Users/${username}/.homebrew/trust.json"
    chown ${username}:staff "/Users/${username}/.homebrew/trust.json"
  '';

  # Machine-specific home-manager config for this work mac. Merges with the
  # shared ./home modules the flake imports for this user.
  home-manager.users.${username} = { config, lib, ... }: {
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
