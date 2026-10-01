# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/cachyos-zsh-config/cachyos-config.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

unsetopt correct
unsetopt correct_all

# History: keep everything on disk too (atuin has its own db; zsh's feeds up-arrow)
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_all_dups hist_reduce_blanks

# Up/Down: substring search over history (plugin is sourced by cachyos-config)
bindkey '^[[A' history-substring-search-up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OB' history-substring-search-down

# Ctrl-R: atuin (up-arrow left to substring search above)
if command -v atuin >/dev/null; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# typo fixes
unalias gf

alias ll="ls -lah"
alias lt="ls -halt"
alias CLEAR="clear"
alias c="clear"
alias C="clear"
alias sl="ls"
alias docker_remove_all='docker rm -f $(docker ps -aq)'
alias MAKE="make"
alias gs="git status"


# dotnet core schenanigans
export DOTNET_ROOT=$HOME/.dotnet
# export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
export PATH="$HOME/.dotnet/tools:$PATH"
export DOTNET_CLI_TELEMETRY_OPTOUT=1

export PATH="$PATH:/opt/rocm/bin"
export PATH="$PATH:/opt/cuda/bin"
export PATH="$PATH:/home/avic/projects/external/aseprite/build/bin"
export PATH="$HOME/opt/cross/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"

lsgit() {
  for d in */; do
    if [ -d "$d/.git" ]; then
      echo "$(git -C "$d" log -1 --format="%ct") $d"
    fi
  done | sort -rn | while read -r ts d; do
    commit_info=$(git -C "$d" log -1 --format="%cd (%cr)")
    printf "%-30s Last commit: %s\n" "$d" "$commit_info"
  done
}
