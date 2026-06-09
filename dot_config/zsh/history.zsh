# Zsh history

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=200000
SAVEHIST=200000

# Write history immediately and share across all shells / tabs.
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# History hygiene.
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt EXTENDED_HISTORY
