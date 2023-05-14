#!/bin/bash

export GOPATH=${HOME}/software/go
sudo apt-get -y install golang
go get golang.org/dl/go1.20.4
go1.20.4 download
go1.20.4 install github.com/charmbracelet/gum@latest
export PATH=${HOME}/software/go/bin:${PATH}

available_castles=("castle-core" "castle-tmux" "castle-coding" "castle-neovim")

castles=$(echo "${available_castles[@]}" | gum choose --height 10 --no-limit)

if [[ ${#castles[@]} -eq 0 ]]; then
	echo "No castles to install. Aborting."
	exit 0
fi

if [[ ! -f $HOME/.homesick/repos/homesick/homesick.sh ]]; then
	git clone https://github.com/michaelrommel/homesick.git "$HOME/.homesick/repos/homesick"
fi

source "$HOME/.homesick/repos/homesick/homesick.sh"

for castle in "${castles[@]}"; do
	homesick -f clone "$castle"
done
