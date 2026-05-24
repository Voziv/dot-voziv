{ ... }:
{
  # Templates are installed by ./default.nix (under home.file).
  # The voziv-sync-secrets binary is installed by ./packages.nix.
  # Nothing runs during `home-manager switch` — secrets stay decoupled from
  # activation so a missing `op` signin can't break a switch.
  #
  # Per-machine workflow:
  #   home-manager switch
  #   eval $(op signin)        # or rely on the 1Password desktop app
  #   voziv-sync-secrets       # renders voziv_config
  #
  # Re-run voziv-sync-secrets any time you rotate or update a secret in 1Password.
}
