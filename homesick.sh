#!/bin/bash

export GOPATH="${HOME}/software/go"
export PATH="${HOME}/software/go/bin:${PATH}"

if ! gum -v; then
	GOVERSION=$(go version | { read _ _ v _; echo ${v#go}; })
	if [[ -z "${GOVERSION}" ]]; then
		echo "Installing default go package"
		sudo apt-get -y install golang
	fi
	GOVERSION=$(go version | { read _ _ v _; echo ${v#go}; })
	if [[ "$(echo "${GOVERSION%.*} < 1.20" | bc)" -eq 1 ]]; then
		echo "Updating go"
		go get golang.org/dl/go1.20.4
		go1.20.4 download
	fi
	go1.20.4 install github.com/charmbracelet/gum@latest
fi

available_castles=(castle-core castle-tmux castle-coding castle-neovim)

selection=$(for c in "${available_castles[@]}"; do echo "$c"; done | gum choose --height 10 --no-limit)
mapfile -t castles < <(echo "${selection[@]}")

if [[ ${#castles[@]} -eq 0 ]]; then
	echo "No castles to install. Aborting."
	exit 0
fi

if [[ ! -f ${HOME}/.homesick/repos/homesick/homesick.sh ]]; then
	git clone https://github.com/michaelrommel/homesick.git "${HOME}/.homesick/repos/homesick"
fi

source "${HOME}/.homesick/repos/homesick/homesick.sh"

for castle in "${castles[@]}"; do
	homesick -f clone "michaelrommel/${castle}"
	homesick -f link "${castle}"
done
