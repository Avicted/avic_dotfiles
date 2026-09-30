# Avic's dotfiles

Public dotfiles repo, mirroring the `~` layout. `init.sh` symlinks each config
into `~`, so editing a live file edits the repo directly. No app state, no
secrets, no machine-local identity.

## Install

```bash
pacman -S git
git clone git@github.com:Avicted/avic_dotfiles.git ~/projects/avic_dotfiles
cd ~/projects/avic_dotfiles
./init.sh              # symlink the configs into ~
./init.sh --packages   # same, but first pacman-install the dev tools in packages.txt
```

Packages are off by default. The list assumes the CachyOS repos (for
`claude-code`) and has no AUR packages.

Yes, this is reinventing Ansible, one pacman -S at a time.

`init.sh` is idempotent: an existing file in `~` is backed up to
`*.bak.<timestamp>` before it's replaced by a symlink. Its header comment covers
the special cases (`~/.claude`, `~/.gitconfig`, `.config/discord`, KDE). If it
warns about a missing locale, run the `sudo` command it prints, or apps
launched from Plasma (like rofi) won't start.

## Usage

```bash
git add -p && git commit -m "update configs" && git push   # after editing a live config
```

To add a new config: copy it into the repo at its `~`-relative path, add it to
`link_authored` in `init.sh`, remove the original, and re-run `./init.sh`.

## Development

Everything goes through `make`. Run it without arguments to get the menu.
The quality gate is pre-commit running in Docker (`Dockerfile.pre-commit`), so
Docker is the only thing it needs. It covers file hygiene, shellcheck, a `zsh -n`
syntax check of `.zshrc`, hadolint and gitleaks.

```bash
make hooks              # run the gate on every commit (and a history secret scan on push)
make pre-commit-pr-run  # the gate on origin/master..HEAD - what CI runs on a PR
make pre-commit-run     # every hook on every file
make secrets            # gitleaks over the working tree and the full git history
```

## Git configuration

`.gitconfig` in this repo has no identity or machine-specific paths.
`~/.gitconfig` is a real, untracked file that includes it:

```ini
[include]
    path = ~/projects/avic_dotfiles/.gitconfig

[user]
    name = Your Name
    email = you@example.com
    signingkey = ~/.ssh/id_ed25519.pub
```

(`init.sh` sets up the `[include]`; add your identity below it.)

Commits are signed with SSH by default. To make local verification and
GitHub's "Verified" badge work:

```bash
printf '%s %s\n' "you@example.com" "$(cut -d' ' -f1,2 ~/.ssh/id_ed25519.pub)" \
  > ~/.ssh/allowed_signers
chmod 644 ~/.ssh/allowed_signers
```

Then add the same public key again on GitHub under **Settings → SSH and GPG
keys → New SSH key**, with **Key type: Signing Key**.

Verify with `git commit --allow-empty -m test && git log --show-signature -1`.
To disable signing, set `commit.gpgsign = false` and `tag.gpgsign = false` in
`~/.gitconfig`.
