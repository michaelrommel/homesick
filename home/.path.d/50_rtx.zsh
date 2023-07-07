#! /usr/bin/env zsh

if [[ -x "${HOME}/bin/rtx" ]]; then
	RTX=${HOME}/bin/rtx
elif [[ -x "/opt/homebrew/bin/rtx" ]]; then
	RTX=/opt/homebrew/bin/rtx
elif [[ -x "/usr/local/bin/rtx" ]]; then
	RTX=/usr/local/bin/rtx
elif [[ -x "/usr/bin/rtx" ]]; then
	RTX=/usr/bin/rtx
else
	unset RTX
fi

# look for version manager
if [[ -n "${RTX}" && ! ":${PATH}:" == *:${HOME}/.local/share/rtx/shims:* ]]; then
	# path has not yet been added
	export PATH="${HOME}/.local/share/rtx/shims:${PATH}"
	eval "$(${RTX} activate zsh)"
fi
