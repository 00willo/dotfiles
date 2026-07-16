# Aliases

# General
alias cl='clear'

# Neovim
alias v='/opt/homebrew/bin/nvim'
alias inv='nvim $(fzf -m --preview="bat --color=always {}")'

# Custom scripts
alias nlof="fzf-list-old-files"
alias nzo="zoxide-open-files-nvim"

# eza, better ls
alias l='eza --icons=auto'
alias ls='eza --icons=auto'
alias ll='eza -lg --icons=auto'
alias la='eza -lag --icons=auto'

# eza tree views
alias lt='eza -lTg --icons=auto'
alias lt1='eza -lTg --level=1 --icons=auto'
alias lt2='eza -lTg --level=2 --icons=auto'
alias lt3='eza -lTg --level=3 --icons=auto'

# eza tree views, including hidden files
alias lta='eza -lTag --icons=auto'
alias lta1='eza -lTag --level=1 --icons=auto'
alias lta2='eza -lTag --level=2 --icons=auto'
alias lta3='eza -lTag --level=3 --icons=auto'

## Make eza-backed aliases use eza completion.
#if (( $+commands[eza] && $+functions[compdef] )); then
#  compdef _eza l ls ll la
#  compdef _eza lt lt1 lt2 lt3
#  compdef _eza lta lta1 lta2 lta3
#fi


# File/path completion for eza-backed ls aliases.
if (( $+functions[compdef] )); then
  compdef _files l
  compdef _files ls
  compdef _files ll
  compdef _files la

  compdef _files lt
  compdef _files lt1
  compdef _files lt2
  compdef _files lt3

  compdef _files lta
  compdef _files lta1
  compdef _files lta2
  compdef _files lta3
fi


# Python
alias py='python3'
alias pip='python3 -m pip'
