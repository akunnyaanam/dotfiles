# Load custom aliases
source "$HOME/.config/aliases"

# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/exa"
plug "zsh-users/zsh-syntax-highlighting"
plug "zap-zsh/vim"
plug "Aloxaf/fzf-tab"
plug "zap-zsh/fzf"
plug "wintermi/zsh-starship"

# No delay vim mode goes brrr
export KEYTIMEOUT=1

# go to project
fp() {
    local project_dir
    project_dir=$(fd '^\.git$' ~/ \
        --hidden \
        --no-ignore \
        --type d \
        --prune \
        --exclude '.cache' \
        --exclude 'node_modules' \
        --exclude '.local' \
        2>/dev/null --exec echo {//} | fzf --height 50% --layout=reverse --border)
    
    if [ -n "$project_dir" ]; then
        cd "$project_dir" 
        zle && zle reset-prompt
    fi
}

# pass
pass-fzf() {
    local target
    target=$(find ~/.password-store -name "*.gpg" | sed "s|${HOME}/.password-store/||; s|.gpg$||" | fzf)
    if [ -n "$target" ]; then
        pass -c "$target"
    fi
}

# Zsh widget wrapper
fp-widget() { fp; }
pass-fzf-widget() { pass-fzf; }
zle -N fp-widget
zle -N pass-fzf

bindkey '^g' fp-widget
bindkey '^p' pass-fzf

# Load and initialise completion system
autoload -Uz compinit
compinit
