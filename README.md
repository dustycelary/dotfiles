# dotfiles

Personal config files for macOS and Raspberry Pi. Structure mirrors `~/` exactly — what you see here is what lives in your home directory.

## How it works

`install.sh` symlinks every file in the `FILES` list to its matching path in `~/`. After that, editing a config file anywhere edits the dotfiles repo directly — there's no copying or saving step.

## Setup on a new machine

```bash
git clone git@github.com:dustycelary/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles && ./install.sh
```

## Daily workflow

Edit any config normally. Then commit and push:

```bash
cd ~/Documents/dotfiles
git add -A
git commit -m "what you changed"
git push
```

Pull changes on another machine:

```bash
cd ~/Documents/dotfiles && git pull
```

## Tracking a new file

```bash
cp ~/.config/foo/bar ~/Documents/dotfiles/.config/foo/bar
# add  .config/foo/bar  to the FILES list in install.sh
./install.sh
```
