# Avic's dotfiles

Dotfiles for my system, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
avic_dotfiles/
├── .config/
│   └── git/        # Global gitignore
│   └── nvim/       # Neovim config
│   └── rofi/       # Rofi config
│   └── ...         # Other app configs
├── .gitconfig      # Git config (see "Git configuration" below)
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

## Git configuration

This repo is public, so the tracked `.gitconfig` contains **no identity and no
machine-specific paths**.

Unlike everything else here, `.gitconfig` is **not** stowed into `$HOME` (it's listed in
`.stow-local-ignore`). Instead `~/.gitconfig` stays a real, untracked file that pulls the
shared config in:

```ini
[include]
    path = ~/projects/avic_dotfiles/.gitconfig
```

The reason is that git resolves symlinks before writing config. If `~/.gitconfig` were a
symlink into this repo, then a stray `git config --global user.email ...` would edit the
**tracked, public** file. With the include, `--global` writes land in the untracked file
where they belong. To edit the shared config on purpose:

```bash
git config --file ~/projects/avic_dotfiles/.gitconfig <key> <value>
```

### Per-machine setup

1. Create `~/.gitconfig`. Settings after the `[include]` override the shared config, so
   local tweaks go at the bottom:

```ini
[include]
    path = ~/projects/avic_dotfiles/.gitconfig

[user]
    name = Your Name
    email = you@example.com
    signingkey = ~/.ssh/id_ed25519.pub

# Repos owned by another uid, work paths, etc.
# [safe]
#     directory = /path/to/some/repo
```

2. Commits are signed by default with SSH. Register the signer so local verification
   works:

```bash
printf '%s %s\n' "you@example.com" "$(cut -d' ' -f1,2 ~/.ssh/id_ed25519.pub)" \
  > ~/.ssh/allowed_signers
chmod 644 ~/.ssh/allowed_signers
```

3. For GitHub to show commits as **Verified**, add the *same* public key a second time at
   **Settings → SSH and GPG keys → New SSH key**, with **Key type: Signing Key**. A key
   added only as an Authentication Key will not verify commits.

To check it works:

```bash
git commit --allow-empty -m "signing test"
git log --show-signature -1   # -> Good "git" signature for you@example.com
```

If you'd rather not sign at all, set `commit.gpgsign = false` and `tag.gpgsign = false`
in `~/.gitconfig`, below the `[include]`.

## Setting up on a new machine

```bash
pacman -S git stow
git clone git@github.com:Avicted/avic_dotfiles.git ~/projects/avic_dotfiles
cd ~/projects/avic_dotfiles
stow -v -t ~ .
```

Then follow [Git configuration](#git-configuration) to create `~/.gitconfig` — stow
deliberately skips that one.