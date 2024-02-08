#! /usr/bin/env bash

# Go location
GOPATH=$(readlink -f "${HOME}/software")/go
export GOPATH

if [[ ! ":${PATH}:" == *:${GOPATH}/bin:* ]]; then
	export PATH="${GOPATH}/bin:${PATH}"
fi

# mise will handle the rest, e.g. adding the correct PATH during interactive sessions
# or via the shim that gets added to the path soon
