# Zsh plugins

if command -v brew >/dev/null 2>&1; then
  zsh_autosuggestions="$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  zsh_syntax_highlighting="$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  if [[ -r "$zsh_autosuggestions" ]]; then
    source "$zsh_autosuggestions"
  fi

  # Keep syntax highlighting near the end of plugin loading.
  if [[ -r "$zsh_syntax_highlighting" ]]; then
    source "$zsh_syntax_highlighting"
  fi
fi
