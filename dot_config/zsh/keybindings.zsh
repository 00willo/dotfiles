# Key bindings

# Show key escape sequences:
#   cat -v
# Then press the key combo you want to identify.

# Cmd + Left / Right: move to start/end of line
# Keys: Cmd + ← / Cmd + →
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# Option + Left / Right: move one word backward/forward
# Keys: Option + ← / Option + →
bindkey '^[b' backward-word
bindkey '^[f' forward-word

# Home / End: move to start/end of line
# Keys: Home / End
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Up / Down: search history using current input as prefix
# Keys: ↑ / ↓
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
