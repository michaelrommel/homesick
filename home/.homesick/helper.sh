#! /usr/bin/env bash

[[ -x "/usr/bin/uname" ]] && UNAME="/usr/bin/uname"
[[ -x "/bin/uname" ]] && UNAME="/bin/uname"

ARCH=$(${UNAME} -m)
OS=$(${UNAME} -o)
OSRELEASE=$("${UNAME}" -r)

get_osarch() {
	echo "${OS}_${ARCH}"
}

is_mac() {
	if [[ "${OS}" == "Darwin" ]]; then return 0; else return 1; fi
}

is_wsl() {
	if [[ "${OSRELEASE}" =~ "-microsoft-" ]]; then return 0; else return 1; fi
}

is_in() {
	local pkg="$1"
	shift
	local packages=("$@")
	for p in "${packages[@]}"; do [[ "$p" == "$pkg" ]] && return 0; done
	return 1
}

satisfied() {
	IFS="." read -r -a required <<<"${1}"
	IFS="." read -r -a actual <<<"${2}"
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

has_version() {
	local pkg="$1"
	shift
	local packages=("$@")
	local VERS="false"

	# get the pure packagename
	local pkg_required="${pkg%%@*}"
	if [[ "${pkg}" =~ @ ]]; then
		VERS="true"
		# get all after the at sign, split on dot
		#IFS="." read -r -a vers_required <<<"${pkg#*@}"
		vers_required="${pkg#*@}"
	fi

	for p in "${packages[@]}"; do
		if [[ "${VERS}" == "true" ]]; then
			local pkg_installed="${p%%@*}"
			if [[ "$pkg_required" == "$pkg_installed" ]]; then
				# there was a version specified
				vers_installed="${p#*@}"
				OK=satisfied "${vers_required}" "${vers_installed}"
				return "$OK"
			fi
			# IFS="." read -r -a vers_installed <<<"${p#*@}"
			# if [[ "$pkg_required" == "$pkg_installed" ]]; then
			# 	if ((${vers_required[0]} > ${vers_installed[0]})); then
			# 		return 1
			# 	else
			# 		if ((${vers_required[0]} == ${vers_installed[0]} && \
			# 			${vers_required[1]} > ${vers_installed[1]})); then
			# 			return 1
			# 		else
			# 			return 0
			# 		fi
			# 	fi
			# fi
		else
			# no version requirement
			local pkg_installed="${p%%@*}"
			if [[ "$pkg" == "$pkg_installed" ]]; then
				return 0
			fi
		fi
	done
	return 1
}

check_brewed() {
	# mutate the named array of the caller
	local -n a=$1
	shift
	local desired=("$@")
	local packages
	mapfile -t packages < <(brew list --versions | sed -e 's/ /@/')
	for n in "${desired[@]}"; do
		if ! has_version "$n" "${packages[@]}"; then
			a+=("${n}")
		fi
	done
}

check_dpkged() {
	# mutate the named array of the caller
	local -n b=$1
	shift
	local desired=("$@")
	local packages
	mapfile -t packages < <(dpkg-query --list | sed -ne 's/^ii *\([^ :]\{1,\}\).* .*\([^ ]\{1,\}\) .*/\1@\2/;t nap;d;:nap;p')
	for n in "${desired[@]}"; do
		if ! has_version "$n" "${packages[@]}"; then
			b+=("${n}")
		fi
	done
}
