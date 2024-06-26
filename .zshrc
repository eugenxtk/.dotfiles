# Set up base for local enviroment
base_executed=~/.dotfiles/base.sh
chmod +x $base_executed && $base_executed

. ~/.nix-profile/etc/profile.d/nix.sh

source ~/.dotfiles/antigen.zsh

# Aliases for frequently used commands 
alias vim="nvim"

pretty_ls()
{
  tput reset	

  last_arg=${@[$#]}
  if ! [[ ${last_arg:0:2} = "--" ]]; then
    if [[ -d $last_arg ]]; then
      if ! [[ ${last_arg: -1} = '/' ]]; then
        last_arg="${last_arg}/"
      fi

      exa "$@"
      echo "\n↑\n\n $last_arg\n"
      echo "$(pwd):"
    else
      echo "ls: Specified directory doesn't exist"
      return
    fi
  else
    exa "$@"
    echo ''
    echo " $(pwd):"
  fi
}

alias cat="bat --paging=never"
alias pcat="bat -r 0:20"
alias ccat="bat --paging=never --style=plain"
alias fcat="bat -r 0:20 *"

export BAT_THEME=1337
alias sls="pretty_ls --icons --all --classify"
alias ls="pretty_ls --icons --all --long"
alias tr='pretty_ls --icons --all --tree --ignore-glob=".git"'

cd() 
{
  if [[ -z $1 ]]; then
    echo "cd: You must specify directory"
    return
  fi
  if [[ ! -d $1 ]]; then
    echo "cd: Specified directory doesn't exist"
    return
  fi

  builtin cd $1
  sls
}

# Install Nix packages
typeset -A nix_packages
nix_packages=(
  git git
  neovim neovim
  tmux tmux
  gnumake gnumake
  gccgo gccgo
  eza eza
  stow stow
  fzf fzf
  fd fd
  ripgrep ripgrep
  bat bat
  xclip xclip
  python312 python3-3.12
  python312Packages.pip python3.12-pip
)

for key ("${(@k)nix_packages}"); do
  pkg=$key pkg_name=$nix_packages[$key]
  if ! [[ "$(nix-env -q)" == *$pkg_name* ]]; then
    echo "Installing $pkg package..."
    nix-env -iA "nixpkgs.$pkg"
  fi
done

# Install Docker
docker_install_script="docker.sh"
if ! command -v docker > /dev/null; then
  sudo bash $docker_install_script
fi

# Push files from '.dotfiles' folder to '~'
builtin cd ~/.dotfiles

stow git
stow nvim
stow tmux
stow git

# Install Antigen plugins
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply

# Show hidden files in autocompletion
setopt globdots

# Change prompt style
export PS1="\$ "

# Run Tmux
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux new-session -A -s main
fi

# Move to `home` directory
cd ~
