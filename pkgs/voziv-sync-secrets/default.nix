{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
, writeShellApplication ? pkgs.writeShellApplication
, _1password-cli ? pkgs._1password-cli
, coreutils ? pkgs.coreutils
}:

writeShellApplication {
  name = "voziv-sync-secrets";

  runtimeInputs = [
    _1password-cli
    coreutils
  ];

  text = builtins.readFile ./voziv-sync-secrets.sh;

  meta = with lib; {
    description = "Render 1Password-templated voziv configs into ~/.voziv (idempotent).";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "voziv-sync-secrets";
  };
}
