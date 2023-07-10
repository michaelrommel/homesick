#! /usr/bin/env bash

# list of paths that should be added
paths=("${HOME}/.local/bin" "${HOME}/.docker/bin" "/usr/local/bin" "/usr/local/opt/avr-gcc@8/bin" "/usr/local/opt/arm-gcc-bin@8/bin")
for p in "${paths[@]}"; do
	if [[ -d "${p}" && ! ":${PATH}:" == *:${p}:* ]]; then
		# path has not yet been added
		export PATH="${p}${PATH:+:${PATH}}"
	fi
done

# home folder bin dir
if [[ -d "${HOME}/bin" ]]; then
	# path needs always to be added to the beginning
	export PATH="${HOME}/bin${PATH:+:${PATH}}"
fi
