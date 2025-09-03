append_path()
{
  if test -d "$1"; then
    case ":$PATH:" in
      *":$1:"*) ;;
      *) export PATH="$PATH:$1" ;;
    esac
  fi
}

prepend_path()
{
  if test -d "$1"; then
        case ":$PATH:" in
          *":$1:"*) ;;
          *) export PATH="$1:$PATH" ;;
        esac
  fi
}

prepend_path "$HOME/bin"
prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.voziv/bin"

append_path "$HOME/.composer/vendor/bin"
append_path "$HOME/.config/composer/vendor/bin"
append_path "$HOME/.linkerd2/bin"
append_path "$HOME/.lmstudio/bin"

append_path "$HOME/.npm-global/bin"
append_path "$HOME/.rd/bin"
append_path "$HOME/bin/nvim/bin"
append_path "$HOME/.tfenv/bin"



# PNPM
export PNPM_HOME="$HOME/.local/share/pnpm"
append_path "$PNPM_HOME"

# Google Cloud
if type -p "gcloud" &> /dev/null; then
  GOOGLE_CLOUD_SDK_HOME="dirname $(dirname $(which gcloud))"
fi
