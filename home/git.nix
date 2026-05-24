{ pkgs, lib, ... }:
let
  # Wrapper that dispatches to the right op-ssh-sign binary at runtime.
  # Handles Mac, Linux (standard /opt/1Password install), and WSL (delegates
  # to the Windows-side binary via /mnt/c/...). Native Windows isn't covered
  # because home-manager doesn't run there — use Git for Windows + manual
  # gitconfig there if needed.
  #
  # Linux path assumes the official 1Password package (Arch AUR, deb/rpm,
  # rpm). Override by editing this script if you use the AppImage or a
  # non-default prefix.
  opSshSign = pkgs.writeShellScript "voziv-op-ssh-sign" ''
    case "$(uname -s)" in
      Darwin*)
        exec "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" "$@"
        ;;
      Linux*)
        if [ -r /proc/version ] && grep -qiE '(microsoft|wsl)' /proc/version; then
          # WSL — invoke the Windows binary via interop. WIN_USER can be set
          # in your shell rc if cmd.exe lookup is too slow or unavailable.
          win_user="''${WIN_USER:-$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n')}"
          exec "/mnt/c/Users/''${win_user}/AppData/Local/1Password/app/8/op-ssh-sign.exe" "$@"
        else
          exec "/opt/1Password/op-ssh-sign" "$@"
        fi
        ;;
      *)
        echo "voziv-op-ssh-sign: unsupported platform $(uname -s)" >&2
        exit 1
        ;;
    esac
  '';

  signingKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCovW9mR+cuHE+iC6hQR8gJD8DRZx4g4e7DKtXh4rFETM6WsKDra9zbLW8N/sHt6pJffgLrTMlo1CT1y6v8BbiXyV5fvUvd9YBV88ZfOJPdg8Ck1IK++Y0fnKJU20tTWIMf37kOedt+0GtZ9jXpHa+ys/FoPbO/fq97+31c0BKL64D+V0bJkCR9oWXMGWAf9iQBmGHQbBXddvAqwibyXaQgF61pifJPR/IzuNvH5LoTdM5S3cMEh33UgHExhi7mjeJEblYFAvrQaHiWsqTJeUZbVUCnjLCPCUwWnTjg8ddeImumWbXMRjkWttfPrj5+3DGGFGMARzERlPQdBpegLnr1W5IIU9Za8Gq86AMdYGVr//WwQaSn4rGW+6HqS4NCb1/khizMA92vrT3nwVB3NrTWPUcjDMd0UdUJ2vIuPTyXjXjaYc9TGCd4p3ccPkaGCn9WRWqdk+Sx/D4R47zjxRgMj2GQYJ6diDPI79nQ9AVpgXreTYlmIlcXiChjsq4Oqhnl/DCgpSAlmx6AKFlrs4v+O5Z+Xj6GoVyqroR7Y6/2uWIFHMozNEmhwcvslk2JVlUoM0nBL/ilWovwSOrO/WH9pkepapnuOIoKylhTlBUJ8qRVrXox80aKDqAYp7lm/9zOZQcsVqXoPWgPSdv0SM+qM58nPEvjV1kF2FgcjBouSw==";
  userEmail = "25726+Voziv@users.noreply.github.com";

  # Allowed-signers file lets `git log --show-signature` verify our own
  # SSH-signed commits locally. namespaces="git" scopes the key to git.
  allowedSigners = pkgs.writeText "git-allowed-signers" ''
    ${userEmail} namespaces="git" ${signingKey}
  '';
in
{
  programs.git = {
    enable = true;

    signing = {
      key = signingKey;
      signByDefault = true;
      format = "ssh";
      signer = "${opSshSign}";
    };

    # diff-so-fancy lives in src/.voziv/bin (and ships in nixpkgs too).
    # pager.diff below keeps the existing pager pipeline.
    settings = {
      user = {
        name  = "Voz";
        email = userEmail;
      };

      # Verify our own SSH-signed commits locally.
      gpg.ssh.allowedSignersFile = "${allowedSigners}";

      alias = {
        ap         = "add --patch";
        br         = "branch";
        ci         = "commit -am";
        co         = "checkout";
        fap        = "fetch --all --prune";
        fp         = "fetch --prune";
        gone       = "!for branch in $(git branch -vv | grep ': gone]' | grep -v $(git branch --show-current) | awk '{print $1}'); do git branch -D $branch; done";
        l          = "log --date=short --pretty=format:'%C(bold blue)%cd %Creset%C(red)%h%Creset%C(auto)%d %Creset%C(normal)%s %Creset%C(bold blue)(%Creset%C(yellow)%an %Creset%C(bold blue)%cr)%Creset' --color --graph --decorate";
        last       = "log -1 HEAD";
        poo        = "push";
        poosh      = "push";
        pushy      = "push";
        pushup     = "push -u origin HEAD";
        st         = "status -bs";
        stag       = "tag --sort=v:refname";
        undo       = "reset --soft HEAD~1";
        unstage    = "reset HEAD --";
      };

      core = {
        excludesfile = "~/.gitignore_global";
        pager = "diff-so-fancy | less --tabs=4 -RFX";
      };
      tag.forceSignAnnotated = true;
      push.default = "simple";
      merge.tool = "kdiff3";
      mergetool.prompt = false;
      "mergetool \"p4merge\"" = {
        cmd = ''p4merge "$BASE" "$LOCAL" "$REMOTE" "$MERGED"'';
        keepTemporaries = false;
        trustExitCode = false;
        keepBackup = false;
      };
      rebase.autoStash = true;
      pull.rebase = true;
      "diff \"sopsdiffer\"".textconv = "sops -d";
      color.ui = true;
      "color \"diff-highlight\"" = {
        oldNormal = "red bold";
        oldHighlight = "red bold 52";
        newNormal = "green bold";
        newHighlight = "green bold 22";
      };
      "color \"diff\"" = {
        meta = 11;
        frag = "magenta bold";
        commit = "yellow bold";
        old = "red bold";
        new = "green bold";
        whitespace = "red reverse";
      };
      pager.diff = "diff-so-fancy | less --tabs=4 -RFXS --pattern '^(Date|added|deleted|modified): '";
      fetch.prune = true;
      init.defaultBranch = "main";
      gitbutler = {
        utmostDiscretion = 1;
        signCommits = true;
      };
    };
  };
}
