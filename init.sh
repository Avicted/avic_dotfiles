#!/usr/bin/env bash
# init.sh - link this dotfiles repo into $HOME. Replaces GNU Stow.
#
# The repo mirrors the home-directory layout. This script creates symlinks from
# $HOME into the repo so that editing a live config (e.g. ~/.config/nvim/init.lua)
# edits the repo file directly - then you just `git add && git commit && git push`.
#
#   * Authored config dirs/files are symlinked whole (apps don't write junk there).
#   * ~/.claude is special-cased: it's made a REAL dir and only the two tracked
#     config files are symlinked in, so Claude's history/plugins/.credentials.json
#     stay local and can never land in this public repo.
#   * ~/.gitconfig is NOT symlinked - it's a real file that [include]s the shared
#     config, so `git config --global` writes locally, never into the public repo.
#   * .config/discord is app state, not config - it is deliberately not linked.
#   * KDE rc files are machine-written state, so only individual keys are set
#     (Meta+Space -> rofi, conky excluded from session restore). Locales used by
#     Plasma are only checked - generating them needs root, so it's left to you.
#   * Packages are opt-in: `./init.sh --packages` (or INSTALL_PACKAGES=1) first
#     installs the dev toolchain listed in packages.txt with pacman.
#
# Idempotent: safe to re-run. Any existing live file/dir is backed up (with a
# .bak.<timestamp> suffix) before being replaced by a symlink.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
BAK_SUFFIX=".bak.$(date +%Y%m%d-%H%M%S)"
INSTALL_PACKAGES="${INSTALL_PACKAGES:-0}"

log()  { printf '\033[1;34m[init]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[init][warn]\033[0m %s\n' "$*" >&2; }

for arg in "$@"; do
  case "$arg" in
    --packages) INSTALL_PACKAGES=1 ;;
    *) printf 'usage: %s [--packages]\n' "$0" >&2; exit 1 ;;
  esac
done

# link_item <live-path> <repo-target>
# Make live-path a symlink to repo-target. Backs up any pre-existing real
# file/dir (or a symlink pointing elsewhere) before relinking.
link_item() {
  local live="$1" target="$2" parent cur
  parent="$(dirname "$live")"
  mkdir -p "$parent"

  if [ -L "$live" ]; then
    cur="$(readlink "$live")"
    if [ "$cur" = "$target" ]; then
      log "ok      $live (already linked)"
      return
    fi
    warn "$live is a symlink to '$cur', not '$target' - backing up and relinking"
    mv "$live" "$live$BAK_SUFFIX"
  elif [ -e "$live" ]; then
    warn "existing $live - backing up to $live$BAK_SUFFIX"
    mv "$live" "$live$BAK_SUFFIX"
  fi

  ln -s "$target" "$live"
  log "linked  $live -> $target"
}

# Authored config: symlink the whole dir (or file) into $HOME.
link_authored() {
  local rel="$1"
  link_item "$HOME_DIR/$rel" "$REPO_DIR/$rel"
}

# ~/.claude: a real dir, with only the tracked config files symlinked in.
setup_claude() {
  local live_dir="$HOME_DIR/.claude"
  if [ -L "$live_dir" ]; then
    warn "$live_dir is a symlink - replacing it with a real dir"
    rm "$live_dir"
  fi
  mkdir -p "$live_dir"
  link_item "$live_dir/settings.json"           "$REPO_DIR/.claude/settings.json"
  link_item "$live_dir/statusline-command.sh"   "$REPO_DIR/.claude/statusline-command.sh"
}

# ~/.gitconfig: a real file that [include]s the shared config (at the top, so
# any local settings below it override the shared ones).
setup_gitconfig() {
  local live="$HOME_DIR/.gitconfig"
  local target="$REPO_DIR/.gitconfig"
  local include_line="path = $target"

  if [ -e "$live" ] && grep -qF "$include_line" "$live" 2>/dev/null; then
    log "ok      ~/.gitconfig already includes the shared config"
    return
  fi

  if [ -e "$live" ]; then
    warn "existing ~/.gitconfig - adding [include] at the top (backing up first)"
    local tmp
    tmp="$(mktemp)"
    printf '[include]\n\t%s\n' "$include_line" > "$tmp"
    cat "$live" >> "$tmp"
    mv "$live" "$live$BAK_SUFFIX"
    mv "$tmp" "$live"
  else
    printf '[include]\n\t%s\n' "$include_line" > "$live"
  fi
  log "linked  ~/.gitconfig includes $target"
}

# KDE Plasma: global shortcut, session restore, conky autostart, locale check.
setup_kde() {
  if ! command -v kwriteconfig6 >/dev/null; then
    warn "kwriteconfig6 not found - skipping KDE setup"
    return
  fi

  # Meta+Space launches rofi (.local/share/applications/rofi-drun.desktop).
  # Also register it with a running kglobalaccel, which otherwise keeps its own
  # in-memory copy and ignores the file until next login.
  kwriteconfig6 --file kglobalshortcutsrc --group services --group rofi-drun.desktop \
    --key _launch "Meta+Space"
  local action="['rofi-drun.desktop', '_launch', 'Rofi App Launcher', 'Rofi App Launcher']"
  local kga=(gdbus call --session -d org.kde.kglobalaccel -o /kglobalaccel)
  if "${kga[@]}" -m org.kde.KGlobalAccel.doRegister "$action" >/dev/null 2>&1; then
    "${kga[@]}" -m org.kde.KGlobalAccel.setForeignShortcut "$action" "[268435488]" >/dev/null # Meta+Space
  fi
  log "ok      Meta+Space -> rofi"

  # Session restore relaunches conky on top of the autostart copy - exclude it.
  kwriteconfig6 --file ksmserverrc --group General --key excludeApps conky
  log "ok      conky excluded from session restore"
  link_item "$HOME_DIR/.config/autostart/conky.desktop" /usr/share/applications/conky.desktop

  # Plasma exports its Region & Language locales to every app; one that isn't
  # generated makes apps like rofi fail with "Failed to set locale".
  local loc
  while read -r loc; do
    if ! locale -a | grep -qxF "${loc/.UTF-8/.utf8}"; then
      warn "locale $loc is used by Plasma but not generated. Fix with:"
      warn "  sudo sed -i 's/^#\\s*$loc UTF-8/$loc UTF-8/' /etc/locale.gen && sudo locale-gen"
    fi
  done < <(sed -n 's/^\(LANG\|LC_[A-Z]*\)=//p' "$HOME_DIR/.config/plasma-localerc" 2>/dev/null | sort -u)
}

# Dev toolchain from packages.txt. Docker's service and group need root and a
# re-login, so those are only printed as hints.
install_packages() {
  if ! command -v pacman >/dev/null; then
    warn "pacman not found - skipping packages"
    return
  fi

  local pkgs
  read -ra pkgs < <(sed 's/#.*//' "$REPO_DIR/packages.txt" | xargs)
  sudo pacman -S --needed "${pkgs[@]}"
  log "ok      packages from packages.txt"

  if ! systemctl is-enabled --quiet docker.service 2>/dev/null; then
    warn "docker is not enabled. Fix with: sudo systemctl enable --now docker.service"
  fi
  if ! id -nG | grep -qw docker; then
    warn "you are not in the docker group. Fix with: sudo usermod -aG docker $USER (then log in again)"
  fi
}

log "repo: $REPO_DIR"
log "home: $HOME_DIR"
echo

# --- Packages (opt-in) -------------------------------------------------------
if [ "$INSTALL_PACKAGES" = 1 ]; then
  install_packages
else
  log "skip    packages (run with --packages to install)"
fi

# --- Authored config (whole dir/file symlinks) -------------------------------
link_authored ".zshrc"
link_authored ".config/MangoHud"
link_authored ".config/alacritty"
link_authored ".config/automation"
link_authored ".config/conky"
link_authored ".config/gamemode"
link_authored ".config/git"
link_authored ".config/nvim"
link_authored ".config/rofi"
link_authored ".local/share/applications/rofi-drun.desktop"

# --- Special cases -----------------------------------------------------------
setup_claude
setup_gitconfig
setup_kde

echo
log "done. To make edits stick: edit the live file, then"
log "  cd $REPO_DIR && git add -p && git commit && git push"
