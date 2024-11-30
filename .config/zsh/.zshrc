# Path
typeset -U path cdpath fpath manpath

path+="~/.config/zsh/plugins/fzf-tab"
fpath+="~/.config/zsh/plugins/fzf-tab"
path+="~/.local/bin"

# set compinit 
autoload -U compinit && compinit

# Load fzf-tab
source ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# History
HISTSIZE="10000"
SAVEHIST="10000"
HISTFILE="~/.config/zsh/zsh_history"

setopt HIST_FCNTL_LOCK
unsetopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
unsetopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
unsetopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY

# Load captppuccin theme
source ~/.config/zsh/plugins/themes/catppuccin_macchiato-zsh-syntax-highlighting.zsh

# Load fzf
source <(fzf --zsh)

FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS
# # Use fzf in fullscreen mode with command line at the top, allow to cycle through results when moving out
# of range at the bottom or start and always use 2 spaces for tab stops. Use bat for preview.
FZF_DEFAULT_OPTS+="
  --no-height
  --layout=reverse
  --border
  --cycle
  --tabstop=2
  --preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# Adjust the colors to match the catppuccin theme.
FZF_DEFAULT_OPTS+=" \
--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
--color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 \
--color=selected-bg:#494d64 \
--multi"
export FZF_DEFAULT_OPTS

if type fd > /dev/null; then
  # Use fd as the default source for fzf.
  # Always follow symbolic links and include hidden files, but exclude VCS data like the .git folder.
  export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'
  # Apply the default command to the ^T key binding.
  export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
fi

# Fzf command completion
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'tree -C {} | head -200'   "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
  esac
}

# Load starship
eval "$(starship init zsh)"

# Aliases
alias -- ..='cd ..'
alias -- ...='cd ../..'
alias -- ....='cd ../../..'
alias -- .....='cd ../../../..'
alias -- ......='cd ../../../../..'
alias -- cat=bat
alias -- cp='cp -i'
alias -- df='df -h'
alias -- dir='dir --color=auto'
alias -- egrep='egrep --color=auto --line-number'
alias -- fgrep='fgrep --color=auto --line-number'
alias -- free='free -m'
alias -- grep='grep --color=auto --line-number'
alias -- hw='hwinfo --short'
alias -- ip='ip -color'
alias -- l.='eza -ald --color=always --group-directories-first --icons .*'
alias -- la='eza -a --color=always --group-directories-first --icons'
alias -- ll='eza -l --color=always --group-directories-first --icons'
alias -- ls='eza -al --color=always --group-directories-first --icons'
alias -- lt='eza -aT --color=always --group-directories-first --icons'
alias -- mv='mv -i'
alias -- pscpu='ps auxf | sort -nr -k 3 | head -5'
alias -- psmem='ps auxf | sort -nr -k 4 | head -5'
alias -- rm='rm -i'
alias -- tarnow='tar -acf '
alias -- untar='tar -zxvf '
alias -- vdir='vdir --color=auto'
alias -- wget='wget -c '

# kitty ssh fix
alias -- ssh='TERM=xterm-256color ssh'

# Load reminaing plugins
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS+=()

source ~/.config/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down