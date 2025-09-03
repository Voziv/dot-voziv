is_linux=1
is_mac=1

case "$(uname -s)" in
  Linux*)     is_linux=0;;
  Darwin*)    is_mac=0;;
  CYGWIN*)    is_linux=0;;
  MINGW*)     is_linux=0;;
  MSYS_NT*)   is_linux=0;;
  *)          echo "Unknown uname: $(uname -s)"
esac

we_are_linux()
{
  return $is_linux
}

we_are_mac()
{
  return $is_mac
}

we_are_popos()
{
  if command -v lsb_release >/dev/null 2>&1; then
    if [ $(lsb_release -si) = "Pop" ]; then
      return 0
    fi
  fi
  return 1
}