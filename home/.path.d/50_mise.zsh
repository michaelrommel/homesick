#! /usr/bin/env zsh

if [[ -x "${HOME}/bin/mise" ]]; then
	MISE=${HOME}/bin/mise
elif [[ -x "/opt/homebrew/bin/mise" ]]; then
	MISE=/opt/homebrew/bin/mise
elif [[ -x "/usr/local/bin/mise" ]]; then
	MISE=/usr/local/bin/mise
elif [[ -x "/usr/bin/mise" ]]; then
	MISE=/usr/bin/mise
else
	unset MISE
fi

# look for version manager
if [[ -n "${MISE}" && ! ":${PATH}:" == *:${HOME}/.local/share/mise/shims:* ]]; then
	# path has not yet been added
	export PATH="${HOME}/.local/share/mise/shims:${PATH}"
	eval "$(${MISE} activate zsh)"
fi
