#! /bin/bash

# Go location
GOPATH=$(readlink -f "${HOME}/software")/go
export GOPATH

# look for go version manager
if [[ -d "${HOME}/.gobrew/bin" && ! ":${PATH}:" == *:${HOME}/.gobrew/bin:* ]]; then
	# path has not yet been added
	export PATH="${GOPATH}/bin:${HOME}/.gobrew/current/bin:${HOME}/.gobrew/bin:${PATH}"
	export GOROOT="${HOME}/.gobrew/current/go"
fi
