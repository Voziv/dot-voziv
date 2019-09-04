## Voziv's portable shell configuration

### Installation

#### 1. Clone repo
First start by cloning the repository to `$HOME/.voziv`

`git clone git@github.com:voziv/dot-voziv $HOME/.voziv`

#### 2. Copy and edit configs 

```sh
cd $HOME/.voziv
cp voziv.conf.example voziv.conf && vi voziv.conf
cp git/gitconfig.private.example git/gitconfig.private && vi git/gitconfig.private
cp ssh/voziv_config.example ssh/voziv_config && vi ssh/voziv_config
```

#### 3. Setup zshrc and bashrc files.
For zsh add to your `~/.zshrc` file: `echo 'source $HOME/.voziv/.zshrc' > $HOME/.zshrc`

For bashrc add to your `~/.bashrc` file: `echo 'source $HOME/.voziv/.bashrc' > $HOME/.bashrc`

#### 3. Install the symlinks to the rest of the files
Finally run the installer: `bash $HOME/.voziv/install.sh`

Do note that this will overwrite symlinks in your home folder. The script
will warn you if you already have existing files such as `.gitconfig`.
If they exist you should review them to make sure you've transferred your 
settings over.

#### 4. Install plugins
git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k


### TODO
- Automate installation of the `~/.zshrc` and `~/.bashrc` files

### FAQ

#### Why don't you symlink the `~/.zshrc`/`~/.bashrc` files?

These rc files may have 3rd party code added to them. Rather than setting up some system to 
detect and load this from a different file we just source our own loaders.

You could optionally empty your rc files before sourcing mine.
