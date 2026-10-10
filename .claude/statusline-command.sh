#!/bin/sh
# Claude Code statusLine command
# Mirrors the Powerlevel10k lean prompt style: dir on git-branch | user@host | model | context%

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
home="$HOME"
# Abbreviate home directory as ~
case "$cwd" in
  "$home"*)
    cwd="~${cwd#"$home"}"
    ;;
esac

branch=$(git -C "$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
model=$(echo "$input" | jq -r '.model.display_name // empty')
user=$(whoami)
host=$(hostname -s)
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# dir segment (cyan-ish)
printf '\033[0;36m%s\033[0m' "$cwd"

# git branch segment
if [ -n "$branch" ]; then
  printf ' \033[0;32mon %s\033[0m' "$branch"
fi

# separator
printf ' \033[0;37m|\033[0m'

# user@host
printf ' \033[0;33m%s@%s\033[0m' "$user" "$host"

# model
if [ -n "$model" ]; then
  printf ' \033[0;37m|\033[0m \033[0;35m%s\033[0m' "$model"
fi

# context usage
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  printf ' \033[0;37m[ctx: %s%%]\033[0m' "$used_int"
fi

# plan usage limits (5-hour session, 7-day week); absent for non-subscribers
# Rounded in jq: printf's %f follows the locale and rejects "23.4" where decimals use a comma.
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty | round')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty | round')
[ -n "$five" ] && printf ' \033[0;37m[5h: %s%%]\033[0m' "$five"
[ -n "$week" ] && printf ' \033[0;37m[7d: %s%%]\033[0m' "$week"

printf '\n'
