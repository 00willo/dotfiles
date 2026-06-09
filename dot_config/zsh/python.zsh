# Python tooling

if command -v pyenv >/dev/null 2>&1; then
    export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

    [[ -d "$PYENV_ROOT/bin" ]] && path=("$PYENV_ROOT/bin" $path)

    if [[ "$OSTYPE" == darwin* ]] && command -v brew >/dev/null 2>&1; then
        alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
    fi

    eval "$(pyenv init - zsh)"
fi
