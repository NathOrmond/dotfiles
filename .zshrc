# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme Configuration
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    # Add other plugins here
)

# Oh My Zsh Configuration
source $ZSH/oh-my-zsh.sh

# Powerlevel10k Configuration
source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# TMUX Auto-Start
if [ "$TMUX" = "" ]; then 
    tmux
fi

# Python Environment Configuration
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# Homebrew and Python compatibility
alias brew='env PATH="${PATH//$(pyenv root)/shims:/}" brew'

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"
# export LANG=en_US.UTF-8

# Preferred editor configuration
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

# Go configuration
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin

# Aliases 
# export GITHUB_TOKEN=$(gh auth token)
