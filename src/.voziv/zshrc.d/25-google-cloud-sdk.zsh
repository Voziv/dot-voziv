#!/bin/zsh
[ -f "$GOOGLE_CLOUD_SDK_HOME/path.zsh.inc" ] && . $GOOGLE_CLOUD_SDK_HOME/path.zsh.inc
[ -f "$GOOGLE_CLOUD_SDK_HOME/completion.zsh.inc" ] && . $GOOGLE_CLOUD_SDK_HOME/completion.zsh.inc

if we_are_mac && type -p "brew" &> /dev/null; then
  gcloud_sdk_share="$(brew --prefix)/share/google-cloud-sdk"
  [ -f "$gcloud_sdk_share/path.zsh.inc" ] && source "$gcloud_sdk_share/path.zsh.inc"
  [ -f "$gcloud_sdk_share/completion.zsh.inc" ] && source "$gcloud_sdk_share/completion.zsh.inc"
fi
