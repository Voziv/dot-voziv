# In PopOS! this becomes problematic.
if we_are_popos; then
  if [ $(lsb_release -sr) = "22.04" ]; then
    export MONGOMS_DISTRO="ubuntu-22.04"
    export MONGOMS_ARCHIVE_NAME="mongodb-linux-x86_64-ubuntu2204-6.0.6.tgz"
  fi
fi