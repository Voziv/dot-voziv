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

    # Languages / runtime managers (NVM stays user-managed via rc.d/20-nvm.sh)
    asdf-vm

    # Container / k8s
    kubectl
    kubernetes-helm
    k9s

    # 1Password CLI (op signin, vault access)
    _1password-cli
  ];
}
