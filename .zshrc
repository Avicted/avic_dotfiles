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

# typo fixes
alias ll="ls -lah"
alias lt="ls -halt"
alias CLEAR="clear"
alias c="clear"
alias C="clear"
alias sl="ls"
alias docker_remove_all='docker rm -f $(docker ps -aq)'
alias MAKE="make"

unalias gf

# dotnet core schenanigans
export DOTNET_ROOT=$HOME/.dotnet
# export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
export PATH="$HOME/.dotnet/tools:$PATH"
export DOTNET_CLI_TELEMETRY_OPTOUT=1

export PATH="$PATH:/opt/rocm/bin"

export PATH="$PATH:/opt/cuda/bin"

export PATH="$PATH:/home/avic/projects/external/aseprite/build/bin"