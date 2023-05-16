#!/bin/bash

GOPATH=$(readlink -f "${HOME}/software")/go
export GOPATH
export PATH="${GOPATH}/bin:${PATH}"

if ! gum -v >/dev/null 2>&1; then
	GOVERSION=$(go version 2>/dev/null | {
		read -r _ _ v _
		echo "${v#go}"
	})
	if [[ -z "${GOVERSION}" ]]; then
		echo "Bootstrapping default go package (takes ca. 45 seconds)"
		LOG=$(
			sudo apt-get -y -q install golang 2>&1
		)
		RET=$?
		if [[ $RET -ne 0 ]]; then
			echo -e "Error bootstrapping go, log was: \\n ${LOG}"
			exit 1
		fi
	fi
	GOVERSION=$(go version 2>/dev/null | {
		read -r _ _ v _
		echo "${v#go}"
	})
	# remove the last smantic version number to make it a float
	if [[ "$(echo "${GOVERSION%.*} < 1.20" | bc)" -eq 1 ]]; then
		echo "Updating go (takes ca. 15 seconds)"
		LOG=$(
			go 2>&1 get golang.org/dl/go1.20.4
			go1.20.4 2>&1 download
		)
		RET=$?
		if [[ $RET -ne 0 ]]; then
			echo -e "Error updating go, log was: \\n ${LOG}"
			exit 1
		fi
	fi
	echo "Installing gum (takes ca. 15 seconds)"
	LOG=$(go1.20.4 2>&1 install github.com/charmbracelet/gum@latest)
	RET=$?
	if [[ $RET -ne 0 ]]; then
		echo -e "Error installing gum, log was: \\n ${LOG}"
		exit 1
	fi
fi

printComma() {
	printf "%s," "${@:1:${#}-1}"
	printf "%s" "${@:${#}}"
}

# printNewline() {
# 	printf "%s\n" "${@:1:${#}-1}"
# 	echo "${@:${#}}"
# }

gum style --border rounded --width 70 --margin "1 1" --align center --italic --bold \
	--foreground 4 "Bootstrapping dotfile manager" "(homesick installation)"

gum format -t markdown <<EOF
Below is a list of several packages, called _castles_. Each castle can
be deployed and used on its own, but may benefit from packages installed
by other castles. For instance, the _neovim_ castle can use rg, fd and other
tools which the _coding_ castle provides.
EOF

gum style --bold --foreground 5 --margin "1 2" "Which castles shall be installed?"

available_castles=(castle-core castle-tmux castle-coding castle-neovim)

selection=$(gum choose --no-limit --selected="$(printComma "${available_castles[@]}")" "${available_castles[@]}")
while read -r castle; do
	if [[ -n ${castle} ]]; then
		castles+=("${castle}")
	fi
done < <(echo "${selection[@]}")

if [[ ! -f ${HOME}/.homesick/repos/homesick/homesick.sh ]]; then
	git clone https://github.com/michaelrommel/homesick.git "${HOME}/.homesick/repos/homesick"
fi

# shellcheck disable=1091
source "${HOME}/.homesick/repos/homesick/homesick.sh"

# link the defaults for a basic account
homesick link -f -b "homesick"

# set up additional castles, if requested
if [[ ${#castles[@]} -eq 0 ]]; then
	echo "No castles to install. Aborting."
	exit 0
fi

for castle in "${castles[@]}"; do
	if ! homesick clone -f -b "michaelrommel/${castle}"; then
		homesick pull "${castle}"
	fi
	if ! homesick link -f -b "${castle}"; then
		continue
	fi
done

gum format -t markdown <<'EOF'
The config files have now been installed, please log off and
back in now. Otherwise the search paths would not be set correctly.

If you have installed the _neovim_ castle, the editor environment is 
now preconfigured to automatically install all necessary language 
servers and linters. In order to trigger this installation, please do 
a 'vim test.py' to simulate editing a python file. The first time 
this is done, it will install all neovim packages, but they are not 
activated until you close and re-open the editor a second time.

Just quit the editor with ':q!' and start the same 'vim test.py' 
command again. This time you should have linting, diagnostics and 
formatting all activated. The neovim ':checkhealth' command provides 
diagnostics if something does not work as expected.

EOF

gum style --bold --foreground 2 --margin "1 2" "The bootstrapping installation is now complete!"
