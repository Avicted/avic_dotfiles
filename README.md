# Avic's dotfiles

Dotfiles for my system, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
avic_dotfiles/
├── .config/
│   └── nvim/       # Neovim config
│   └── rofi/       # Rofi config
│   └── ...         # Other app configs
├── .zshrc          # Zsh config
└── README.md
```

The repo mirrors the home directory layout. Stow creates symlinks from `~` into this repo, so editing `~/.config/nvim/init.lua` edits the repo file directly.

## Requirements

```
pacman -S git stow
```

## Installation

1. Clone the repo:

```bash
git clone git@github.com:Avicted/avic_dotfiles.git ~/projects/avic_dotfiles
cd ~/projects/avic_dotfiles
```

2. Back up any existing config files that would conflict:

```bash
# Example: back up nvim and zsh configs before stow replaces them
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.zshrc ~/.zshrc.bak
```

3. Create symlinks with stow (targeting your home directory):

```bash
stow -v -t ~ .
```

## Updating configs

Since stow creates symlinks, any config edits happen inside the repo automatically. Just commit and push:

```bash
cd ~/projects/avic_dotfiles
git add -A
git commit -m "update configs"
git push
```

## Adding a new config

1. Copy the config into the repo, preserving the path relative to `~`:

```bash
# Example: adding kitty terminal config
cp -r ~/.config/kitty ~/projects/avic_dotfiles/.config/kitty
```

2. Remove the original and re-run stow:

```bash
rm -rf ~/.config/kitty
stow -v -t ~ .
```

3. Commit the new config:

```bash
git add -A && git commit -m "add kitty config"
```

## Setting up on a new machine

```bash
pacman -S git stow
git clone git@github.com:Avicted/avic_dotfiles.git ~/projects/avic_dotfiles
cd ~/projects/avic_dotfiles
stow -v -t ~ .
```