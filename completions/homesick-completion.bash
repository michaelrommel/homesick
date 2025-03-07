#!bash
#
###############################################################################
#
# Bash completion for homesick (https://github.com/andsens/homesick).
#
# To use, add this line (or equivalent) to your .bashrc:
#
#   source ~/.homesick/repos/homesick/completions/homesick-completion.bash
#
###############################################################################
#
# Copyright (C) 2013 Jeremy Lin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
###############################################################################

_homesick_basename()
{
    echo "${1##*/}"
}

_homesick_castles()
{
    local repos="$HOME/.homesick/repos"
    # This should be a while loop like in link.sh, leave it for now though
    # shellcheck disable=SC2044
    for repo in $(find -L "$repos" -mindepth 2 -maxdepth 2 -type d -name .git); do
        _homesick_basename "${repo%/.git}"
    done
}

_homesick_complete_castles()
{
    COMPREPLY=($(compgen -W "$(_homesick_castles)" -- "$1"))
}

_homesick_complete()
{
    # The comments at the bottom of the file explain what's going on here.
    if $_HOMESICK_HAS_COMPOPT; then
        compopt +o default +o nospace
        COMPREPLY=()
    else
        COMPREPLY=('')
    fi

    local -r cmds='
        cd
        clone
        generate
        list
        ls
        check
        refresh
        pull
        link
        track
        help
        symlink
        updates
    '
    local -r short_opts='-q      -s     -f      -b      -v'
    local -r long_opts='--quiet --skip --force --batch --verbose'
    local -r protocols='file ftp ftps git http https rsync ssh'

    # Scan through the command line and find the homesick command
    # (if present), as well as its expected position.
    local cmd
    local cmd_index=1 # Expected index of the command token.
    local i
    for (( i = 1; i < ${#COMP_WORDS[@]}; i++ )); do
        local word="${COMP_WORDS[i]}"
        case "$word" in
            -*)
                ((cmd_index++))
                ;;
            *)
                cmd="$word"
                break
                ;;
        esac
    done

    local cur="${COMP_WORDS[COMP_CWORD]}"

    if (( COMP_CWORD < cmd_index )); then
        # Offer option completions.
        case "$cur" in
            --*)
                COMPREPLY=($(compgen -W "$long_opts" -- "$cur"))
                ;;
            -*)
                COMPREPLY=($(compgen -W "$short_opts" -- "$cur"))
                ;;
            *)
                # Skip completion; we should never get here.
                ;;
        esac
    elif (( COMP_CWORD == cmd_index )); then
        # Offer command name completions.
        COMPREPLY=($(compgen -W "$cmds" -- "$cur"))
    else
        # Offer command argument completions.
        case "$cmd" in
            check | pull | link | symlink | updates)
                # Offer one or more castle name completions.
                _homesick_complete_castles "$cur"
                ;;
            cd)
                # Offer exactly one castle name completion.
                if (( COMP_CWORD == cmd_index + 1 )); then
                    _homesick_complete_castles "$cur"
                fi
                ;;
            refresh)
                # Offer a numerical completion for DAYS (mostly as a reminder
                # that this argument should be a number), then castle name
                # completions after that.
                if (( COMP_CWORD == cmd_index + 1 )); then
                    COMPREPLY=({0..9})
                else
                    _homesick_complete_castles "$cur"
                fi
                ;;
            track)
                # Offer one castle name completion, then filename completions
                # after that.
                if (( COMP_CWORD == cmd_index + 1 )); then
                    _homesick_complete_castles "$cur"
                else
                    $_HOMESICK_HAS_COMPOPT && compopt -o default
                    # Let the default Readline filename completion take over.
                    COMPREPLY=()
                fi
                ;;
            clone)
                # Offer an initial protocol completion.
                if (( COMP_CWORD == cmd_index + 1 )); then
                    $_HOMESICK_HAS_COMPOPT && compopt -o nospace
                    COMPREPLY=($(compgen -W "$protocols" -S '://' -- "$cur"))
                fi
                ;;
            help)
                # Offer exactly one command name completion.
                if (( COMP_CWORD == cmd_index + 1 )); then
                    COMPREPLY=($(compgen -W "$cmds" -- "$cur"))
                fi
                ;;
            *)
                # Unknown command or unknowable argument.
                ;;
        esac
    fi
}

# The behavior of 'compgen -f' is pretty bizarre, in that if there's a
# directory 'foo', then compgen simply completes 'foo' and moves on, rather
# than offering to complete names of files underneath 'foo', which is what
# Bash (or Readline, actually) usually does.
#
# You can get the usual Readline filename completion behavior by doing
# 'complete -o default -F <func>', in which case the Readline filename
# completer is called if COMPREPLY=(). But this also means that you can no
# longer deny completion with COMPREPLY=() -- now Readline will always offer
# to complete a filename, even if this is inappropriate (e.g., the command
# takes no further arguments).
#
# In Bash 4.0 and above, there's a way to work around this problem. These
# versions have a 'compopt' builtin, which allows '-o default' to be enabled
# or disabled as needed. The workaround, then, is to disable '-o default'
# at the top of the completion function, and enable it as needed later on.
#
# For older Bash releases, there's a different workaround that doesn't work
# quite as well, but is still better than nothing. This workaround is to
# always enable '-o default' (which can't be disabled later), and then to use
# COMPREPLY=('') to semi-deny completion. That is, pressing Tab will just add
# space characters to the command line, rather than generating filenames.
#
if type compopt &>/dev/null; then
    _HOMESICK_HAS_COMPOPT=true
else
    _HOMESICK_HAS_COMPOPT=false
fi
complete -o default -F _homesick_complete homesick
