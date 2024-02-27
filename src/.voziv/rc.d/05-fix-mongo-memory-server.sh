
# In PopOS! this becomes problematic.
if [ $(lsb_release -si) = "Pop" ]; then
  if [ $(lsb_release -sr) = "22.04" ]; then
    export MONGOMS_DISTRO="ubuntu-22.04"
  fi
fi