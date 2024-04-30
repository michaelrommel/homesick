#!/bin/bash

VERS_GO=1.22@latest
VERS_GUM=latest

GOPATH=$(readlink -f "${HOME}/software")/go
export GOPATH
export PATH="${GOPATH}/bin:${PATH}"

get_os() {
	os="$(uname -s)"
	if [ "$os" = Darwin ]; then
		echo "macos"
	elif [ "$os" = Linux ]; then
		echo "linux"
	else
		error "unsupported OS: $os"
	fi
}

get_arch() {
	arch="$(uname -m)"
	if [ "$arch" = x86_64 ]; then
		echo "x64"
	elif [ "$arch" = aarch64 ] || [ "$arch" = arm64 ]; then
		echo "arm64"
	else
		error "unsupported architecture: $arch"
	fi
}

install_mise() {
	echo "Installing mise"
	os="$(get_os)"
	if [[ "${os}" == "macos" ]]; then
		brew install mise
		MISE=mise
	else
		arch="$(get_arch)"
		mkdir -p "${HOME}/bin"
		latest=$(curl -s https://api.github.com/repositories/586920414/tags | jq -r ".[0].name")
		echo "Latest release seems to be: ${latest}"
		if ! curl -sL "https://github.com/jdx/mise/releases/download/${latest}/mise-${latest}-${os}-${arch}" >"${HOME}/bin/mise"; then
			echo "Download failed. Aborting."
			exit 1
		fi
		chmod 755 "${HOME}/bin/mise"
		MISE="${HOME}/bin/mise"
		export PATH="${HOME}/.local/share/mise/shims:${PATH}"
		eval "$(${MISE} activate bash)"
	fi
}

satisfied() {
	IFS="." read -r -a required <<<"${1#*@}"
	IFS="." read -r -a actual <<<"${2#*@}"
	if ((required[0] > actual[0])); then
		return 1
	else
		if ((required[0] == actual[0] && \
			required[1] > actual[1])); then
			return 1
		else
			return 0
		fi
	fi
}

QUICK=0
while getopts ":q" opt; do
	case $opt in
	q) QUICK=1 ;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		;;
	esac
done

# check prerequisites
PREREQMISS=0
for p in git curl jq; do
	if ! $p --version >/dev/null 2>&1; then
		echo "Prerequisite missing: $p"
		PREREQMISS=1
	fi
done
if [[ $PREREQMISS -gt 0 ]]; then
	exit 1
fi

# Always install mise
install_mise

# Always install homesick, if not already present
if [[ ! -f ${HOME}/.homesick/repos/homesick/homesick.sh ]]; then
	echo "Installing homesick"
	git clone https://github.com/michaelrommel/homesick.git "${HOME}/.homesick/repos/homesick"
else
	echo "Updating homesick"
	pushd "${HOME}/.homesick/repos/homesick" || exit
	git pull
	popd || exit
fi

if [[ ! -f ${HOME}/.zshrc ]]; then
	# shellcheck disable=SC2016
	echo 'source "${HOME}/.minimalrc"' >"${HOME}/.zshrc"
else
	if ! grep ".minimalrc" "${HOME}/.zshrc"; then
		# shellcheck disable=SC2016
		echo 'source "${HOME}/.minimalrc"' >>"${HOME}/.zshrc"
	fi
fi

# shellcheck disable=1091
source "${HOME}/.homesick/repos/homesick/homesick.sh"

# link the defaults for a basic account
homesick link -f -b "homesick"

if [[ "${QUICK}" -eq 1 ]]; then
	echo "Quick installation, exiting early."
	exit 0
fi

if ! gum -v >/dev/null 2>&1; then
	GOVERSION=$(go version 2>/dev/null | {
		read -r _ _ v _
		echo "${v#go}"
	})
	# compare the semantic minor versions
	satisfied "${VERS_GO%@*}" "${GOVERSION}"
	OK=$?
	if [[ -z "${GOVERSION}" || ! $OK ]]; then
		echo "Updating go (takes ca. 15 seconds)"
		LOG=$(
			"${MISE}" 2>&1 plugin install go
			"${MISE}" 2>&1 install go@latest
			"${MISE}" 2>&1 use -g go@latest
		)
		RET=$?
		if [[ $RET -ne 0 ]]; then
			echo -e "Error updating go, log was: \\n ${LOG}"
			exit 1
		fi
	fi

	echo "Installing gum (takes ca. 15 seconds)"
	LOG=$("${HOME}/.local/share/mise/shims/go" 2>&1 install github.com/charmbracelet/gum@${VERS_GUM})
	RET=$?
	if [[ $RET -ne 0 ]]; then
		echo -e "Error installing gum, log was: \\n ${LOG}"
		exit 1
	fi
fi

# printNewline() {
# 	printf "%s\n" "${@:1:${#}-1}"
# 	echo "${@:${#}}"
# }

printComma() {
	printf "%s," "${@:1:${#}-1}"
	printf "%s" "${@:${#}}"
}

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
