#! /bin/bash

# Go location
GOPATH=$(readlink -f "${HOME}/software")/go
export GOPATH

if [[ ! ":${PATH}:" == *:${GOPATH}/bin:* ]]; then
	export PATH="${GOPATH}/bin:${PATH}"
fi

# look for go version manager
if [[ -d "${HOME}/.gobrew/bin" && ! ":${PATH}:" == *:${HOME}/.gobrew/bin:* ]]; then
	# path has not yet been added
	export PATH="${HOME}/.gobrew/current/bin:${HOME}/.gobrew/bin:${PATH}"
	export GOROOT="${HOME}/.gobrew/current/go"
fi
