#! /bin/bash

# home folder bin dir
if [[ -d "${HOME}/bin" && ! ":${PATH}:" == *:${HOME}/bin:* ]]; then
	# path has not yet been added
	export PATH="${HOME}/bin:${HOME}/.local/bin:/usr/local/bin:/usr/local/opt/avr-gcc@8/bin:/usr/local/opt/arm-gcc-bin@8/bin:${PATH}"
fi
