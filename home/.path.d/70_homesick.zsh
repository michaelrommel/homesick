#! /bin/bash

if [[ -f "${HOME}/.homesick/repos/homesick/homesick.sh" ]]; then
	source "${HOME}/.homesick/repos/homesick/homesick.sh"
	fpath=(${HOME}/.homesick/repos/homesick/completions $fpath)
fi
