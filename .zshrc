[[ -f ~/.config/aliases ]] && source ~/.config/aliases
[[ -f ~/.profile ]] && source ~/.profile

[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/exa"
plug "zsh-users/zsh-syntax-highlighting"
plug "zap-zsh/vim"
plug "Aloxaf/fzf-tab"
plug "zap-zsh/fzf"

# No delay vim mode goes brrr
export KEYTIMEOUT=1

# Load and initialise completion system
autoload -Uz compinit
compinit

eval "$(starship init zsh)"
