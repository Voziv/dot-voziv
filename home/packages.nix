{ pkgs, self, ... }:
{
  home.packages = with pkgs; [
    # Core CLI
    fzf
    ripgrep
    fd
    bat
    tree
    jq
    yq-go

    # Git tooling (delta replaces diff-so-fancy if you prefer; both work)
    git-lfs
    gh

    # Shell extras
    direnv
    nix-direnv

    # Languages / runtime managers (NVM stays user-managed via rc.d/20-nvm.sh)
    asdf-vm

    # Container / k8s
    kubectl
    kubernetes-helm
    k9s

    # 1Password CLI (used by voziv-sync-secrets)
    _1password-cli

    # The sync script itself (built from this flake)
    (self.packages.${pkgs.stdenv.hostPlatform.system}.voziv-sync-secrets or
      (pkgs.callPackage ../pkgs/voziv-sync-secrets { }))
  ];
}
