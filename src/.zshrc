# $HOME/.zshrc

# load all files from .voziv/rc.d directory
if [ -d $HOME/.voziv/rc.d ]; then
  for file in $HOME/.voziv/rc.d/*.sh; do
    . $file
  done
fi

# load all files from .voziv/zshrc.d directory
if [ -d $HOME/.voziv/zshrc.d ]; then
  for file in $HOME/.voziv/zshrc.d/*.zsh; do
    . $file
  done
fi


