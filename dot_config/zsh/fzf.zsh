# FZF

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"

  export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

  export FZF_DEFAULT_OPTS="--height 50% --layout=default --border --color=hl:#2dd4bf"

  export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :500 {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --icons=always --tree --color=always {} | head -200'"

  # Optional tuning:
  # export FZF_CTRL_R_OPTS="--tac --exact --preview 'echo {}' --preview-window=down:3:wrap"
  # export FZF_TMUX_OPTS="-p90%,70%"
fi

# FZF with Git by Junegunn:
# Keymaps: https://github.com/junegunn/fzf-git.sh
if [[ -r "$HOME/scripts/fzf-git.sh" ]]; then
  source "$HOME/scripts/fzf-git.sh"
fi
