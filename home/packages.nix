{ pkgs, ... }:
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

    # Closure diff viewer — used by the `hms` preview before switching
    nvd

    # Languages / runtime managers (NVM stays user-managed via rc.d/20-nvm.sh)
    asdf-vm

    # Container / k8s
    kubectl
    kubernetes-helm
    k9s
    argocd

    # Languages
    go
    bun

    # Crypto / signing
    gnupg
  ];
  # 1Password CLI (op) is installed per-host where 1Password is actually used
  # (darwin/hosts/voziv-mac.nix, home/linux.nix) — not on machines without it.
}
