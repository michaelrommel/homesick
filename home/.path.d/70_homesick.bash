#! /bin/bash

if [[ -f "${HOME}/.homesick/repos/homesick/homesick.sh" ]]; then
	# shellcheck source=./homesick.sh
	source "${HOME}/.homesick/repos/homesick/homesick.sh"
	# shellcheck source=./completions/homesick-completion.bash
	source "${HOME}/.homesick/repos/homesick/completions/homesick-completion.bash"
fi
