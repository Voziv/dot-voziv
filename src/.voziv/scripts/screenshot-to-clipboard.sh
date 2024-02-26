#!/bin/sh
#
# Requires gnome-screenshot and xclip to be installed
#
# Go to Settings → Keyboard → View and Customize Shortcuts → Custom Shortcuts.
#
# Name:     Print to clipboard
# Command:  sh /home/voziv/.voziv/scripts/screenshot-to-clipboard.sh
# Shortcut: Shift + Ctrl + Print
#
# Note: Path in the Command must be absolute
#
TMPFILE=`mktemp -u /tmp/screenshotclip.XXXXXXXX.png`
gnome-screenshot -af $TMPFILE && xclip $TMPFILE -selection clipboard -target image/png;
rm $TMPFILE || echo ""
