# Avic's dotfiles

Dotfiles for my system. The repo mirrors the home-directory layout; `init.sh`
creates symlinks from `~` into the repo so that editing a live config (e.g.
`~/.config/nvim/init.lua`) edits the repo file directly.

This is a **public** repo, so it only contains config I'm happy to publish - no
app state, no secrets, no machine-local identity.

## How it works

`init.sh` (run from the repo) symlinks each config into `~`. It is **not** GNU
Stow - it's a small script so the special cases below are explicit:

- **Authored config** (`.zshrc`, `.config/{nvim,rofi,conky,alacritty,gamemode,
  MangoHud,git,automation}`) is symlinked whole. Apps don't write runtime junk
  into these dirs (e.g. nvim's plugins live in `~/.local/share/nvim`, not here).
- **`~/.claude`** is made a *real* dir, and only `settings.json` +
  `statusline-command.sh` are symlinked into it. Claude Code's history, plugins
  and `.credentials.json` stay local and can never land in this repo.
- **`~/.gitconfig`** is *not* symlinked - it's a real file that `[include]`s the
  shared config, so `git config --global` writes locally, never into the repo.
  See [Git configuration](#git-configuration).
- **`.config/discord`** is app state, not config - it's deliberately not linked
  and not tracked.

`init.sh` is idempotent and safe to re-run: any pre-existing live file/dir is
backed up to `*.bak.<timestamp>` before being replaced by a symlink.

## Requirements

```
pacman -S git
```

## Installation / new machine

```bash
git clone git@github.com:Avicted/avic_dotfiles.git ~/projects/avic_dotfiles
cd ~/projects/avic_dotfiles
./init.sh
```

Then follow [Git configuration](#git-configuration) to set up `~/.gitconfig`
(`init.sh` creates the `[include]` for you; you add your identity below it).

## Updating configs

Edits to a live config edit the repo file directly (it's a symlink). Just commit
and push:

```bash
cd ~/projects/avic_dotfiles
git add -p
git commit -m "update configs"
git push
```

## Adding a new config

1. Copy the config into the repo, preserving the path relative to `~`:

   ```bash
   # Example: kitty terminal config
   cp -r ~/.config/kitty ~/projects/avic_dotfiles/.config/kitty
   ```

2. Add it to the `link_authored ...` list in `init.sh`, then remove the original
   and re-run:

   ```bash
   rm -rf ~/.config/kitty
   ./init.sh
   ```

3. Commit:

   ```bash
   git add -p && git commit -m "add kitty config"
   ```

If the app writes runtime data into its config dir (like Claude or Discord do),
don't just add it to the list - special-case it in `init.sh` the way `~/.claude`
is (real dir + symlink only the files you actually want to publish).

## Git configuration

This repo is public, so the tracked `.gitconfig` contains **no identity and no
machine-specific paths**.

`~/.gitconfig` is a real, untracked file that pulls the shared config in:

```ini
[include]
    path = ~/projects/avic_dotfiles/.gitconfig
```

The reason it's not a symlink: git resolves symlinks before writing config. If
`~/.gitconfig` were a symlink into this repo, a stray `git config --global
user.email ...` would edit the **tracked, public** file. With the include,
`--global` writes land in the untracked file where they belong. To edit the shared
config on purpose:

```bash
git config --file ~/projects/avic_dotfiles/.gitconfig <key> <value>
```

### Per-machine setup

1. Create/complete `~/.gitconfig`. Settings after the `[include]` override the
   shared config, so local tweaks go at the bottom:

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

2. Commits are signed by default with SSH. Register the signer so local
   verification works:

   ```bash
   printf '%s %s\n' "you@example.com" "$(cut -d' ' -f1,2 ~/.ssh/id_ed25519.pub)" \
     > ~/.ssh/allowed_signers
   chmod 644 ~/.ssh/allowed_signers
   ```

3. For GitHub to show commits as **Verified**, add the *same* public key a second
   time at **Settings → SSH and GPG keys → New SSH key**, with **Key type:
   Signing Key**. A key added only as an Authentication Key will not verify
   commits.

To check it works:

```bash
git commit --allow-empty -m "signing test"
git log --show-signature -1   # -> Good "git" signature for you@example.com
```

If you'd rather not sign at all, set `commit.gpgsign = false` and `tag.gpgsign =
false` in `~/.gitconfig`, below the `[include]`.
