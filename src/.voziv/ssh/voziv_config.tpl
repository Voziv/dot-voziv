# voziv_config.tpl — rendered to voziv_config by `voziv-sync-secrets`.
#
# Included from ~/.ssh/config via:  Include voziv_config
#
# 1Password references use the format: op://<vault>/<item>/<field>.
# Replace the placeholders below with refs from YOUR vault items, then commit
# the template. Run `voziv-sync-secrets` to materialize the rendered file.

Host voziv-*
    ForwardAgent yes
    User lrobert

#
# Home
#
Host voziv-home-server
    HostName 10.0.0.1
