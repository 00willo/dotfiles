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
