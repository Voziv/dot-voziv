# RVM needs to be last otherwise it complains about not being in first place in the PATH.
if test -f "/etc/profile.d/rvm.sh"; then
  source /etc/profile.d/rvm.sh
fi
