# editor
export EDITOR=/usr/bin/vim

typeset -U path  # Deduplicate array
path=(
        $HOME/.local/bin
        $HOME/scripts
        $path  # Existing system paths
    )

# bc defaults
export BC_ENV_ARGS=/$HOME/.bc

# terminal color
export GREP_COLOR='01:31'

## Colored man pages ##
export MANPAGER="less -R --use-color -Dd+b -Du+y"
export MANROFFOPT="-P -c"
