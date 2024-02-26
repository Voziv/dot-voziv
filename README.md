## Voziv's portable shell configuration

### Prerequisites

Install deps: `apt install zsh fzf`

Install oh-my-zsh `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

Reminder: You'll have to logout when changing your shell for it to take effect by default in the terminal app.

### Installation

#### 1. Clone repo
First start by cloning the repository to your projects folder, eg: `~/dev/voziv/dot-voziv`

`git clone --recurse-submodules git@github.com:voziv/dot-voziv`

#### 2. Copy and edit configs 

```sh
cd dot-voziv
cd src/.voziv/git
cp gitconfig.private.example gitconfig.private && vi git/gitconfig.private
cd ../ssh
cp voziv_config.example voziv_config && vi voziv_config
```

#### 3. Stow!

Run `stow -t $HOME src`

In cases where files already exist you may need to add the `--adopt` flag. If you do this you'll need to check and revert the changes in this repo after adoption.

It's worth noting that you may want to merge the changes. That's an excerise for the reader :)


#### 4. Optional configuration

SSH config:
```
```

#### 4. Install plugins
git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k

