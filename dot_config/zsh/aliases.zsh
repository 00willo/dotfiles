# Aliases

# General
alias cl='clear'

# Neovim
alias v='/opt/homebrew/bin/nvim'
alias inv='nvim $(fzf -m --preview="bat --color=always {}")'

# Custom scripts
alias nlof="$HOME/scripts/fzf_listoldfiles.sh"
alias nzo="$HOME/scripts/zoxide_openfiles_nvim.sh"

# eza, better ls
alias l='eza --icons'
alias ls='eza --icons'
alias ll='eza -lg --icons'
alias la='eza -lag --icons'

# eza tree views
alias lt='eza -lTg --icons'
alias lt1='eza -lTg --level=1 --icons'
alias lt2='eza -lTg --level=2 --icons'
alias lt3='eza -lTg --level=3 --icons'

# eza tree views, including hidden files
alias lta='eza -lTag --icons'
alias lta1='eza -lTag --level=1 --icons'
alias lta2='eza -lTag --level=2 --icons'
alias lta3='eza -lTag --level=3 --icons'

# Python
alias py='python3'
alias pip='python3 -m pip'
