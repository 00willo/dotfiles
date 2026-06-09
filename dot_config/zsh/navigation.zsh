# Navigation helpers

# cd using zoxide, then list directory.
# cx() {
#   z "$@" && l
# }

# Fuzzy cd, excluding Library and hidden directories.
# fcd() {
#   local dir
#   dir="$(find . \( -path './Library' -prune \) -o \( -type d -not -path '*/.*' \) 2>/dev/null | fzf)"
#   [[ -n "$dir" ]] && cd "$dir" && l
# }

# Fuzzy open file in Neovim, excluding Library and hidden files.
# fv() {
#   local file
#   file="$(find . \( -path './Library' -prune \) -o \( -type f -not -path '*/.*' \) 2>/dev/null | fzf)"
#   [[ -n "$file" ]] && nvim "$file"
# }
