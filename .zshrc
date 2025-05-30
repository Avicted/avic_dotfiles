plugins=(git zsh-autosuggestions)

autoload -Uz compinit
compinit

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set the default theme. You can change "robbyrussell" to any theme you like.
ZSH_THEME=robbyrussell

# Source your oh-my-zsh configuration.
source $ZSH/oh-my-zsh.sh

export HOSTNAME="rayleigh"

# Customize the command prompt
# export PS1="%n@%m %~ # "
# export PS1="[${USER}@${HOSTNAME}]# "

SAVEHIST=1000  # Save most-recent 1000 lines
HISTFILE=~/.zsh_history

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

# Aseprite, Skia
export SKIA_DIR="/home/avic/projects/skia/skia"
export SKIA_LIBRARY_DIR="$SKIA_DIR/out/Release"
export SKIA_LIBRARY="/home/avic/projects/skia/skia/out/Release-x64/libskia.a"
export FREETYPE_LIBRARY="/usr/lib/libfreetype.so"
export HARFBUZZ_LIBRARY="/usr/lib/libharfbuzz.so"

export PATH="$PATH:/home/avic/projects/aseprite/build/bin"

export PATH="$PATH:/opt/rocm/bin"

export PATH="$PATH:/opt/cuda/bin/"

# SPIRV
export PATH="$PATH:/home/avic/projects/SPIRV-Cross/build"

# DirectX Shader Compiler
export PATH="$PATH:/home/avic/projects/DirectXShaderCompiler/build/bin"

# Shadercross Compiler
export PATH="$PATH:/home/avic/projects/SDL_shadercross"

# Emscripten
export PATH="$PATH:/home/avic/projects/emsdk"
export PATH="$PATH:/home/avic/projects/emsdk/upstream/emscripten"

