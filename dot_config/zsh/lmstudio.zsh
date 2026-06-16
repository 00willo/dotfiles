# LM Studio CLI path.
# Installed by LM Studio under ~/.lmstudio/bin.

_lmstudio_bin="$HOME/.lmstudio/bin"

if [[ -d "$_lmstudio_bin" ]]; then
  path+=("$_lmstudio_bin")
fi

unset _lmstudio_bin
