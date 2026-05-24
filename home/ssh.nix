{ lib, pkgs, ... }:
let
  # 1Password SSH agent socket — path differs per platform. Quoted on macOS
  # because the path contains spaces (ssh_config splits unquoted values).
  identityAgent =
    if pkgs.stdenv.isDarwin
    then ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
    else "~/.1password/agent.sock";
in
{
  programs.ssh = {
    enable = true;

    # Every block is defined explicitly below, so skip home-manager's legacy
    # implicit `Host *` defaults (and the deprecation warning they now emit).
    enableDefaultConfig = false;

    settings = {
      "voziv-home-server".HostName = "10.0.0.1";

      "voziv-*" = lib.hm.dag.entryAfter [ "voziv-home-server" ] {
        ForwardAgent = true;
        User = "lrobert";
      };

      # Catch-all last so the specific blocks above take precedence.
      "*" = lib.hm.dag.entryAfter [ "voziv-*" ] {
        IdentityAgent = identityAgent;
        SetEnv = { TERM = "xterm-256color"; };
      };
    };
  };
}
