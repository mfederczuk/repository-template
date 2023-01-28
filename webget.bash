# Copyright (c) 2023 Michael Federczuk
# SPDX-License-Identifier: MPL-2.0 AND Apache-2.0

case "$-" in
	(*'i'*)
		if \command test -n "${BASH_VERSION-}"; then
			# using `eval` here in case a non-Bash shell tries to parse this branch even if the condition is false
			\command eval "\\command printf '%s: ' \"\${BASH_SOURCE[0]}\" >&2"
		fi

		\command printf 'script was called interactively\n' >&2
		return 124
		;;
esac

set -o errexit
set -o nounset

# enabling POSIX-compliant behavior for GNU programs
export POSIXLY_CORRECT=yes POSIX_ME_HARDER=yes

if [ -z "${BASH_VERSION-}" ]; then
	if [ "${0#/}" = "$0" ]; then
		argv0="$0"
	else
		argv0="$(basename -- "$0" && printf x)"
		argv0="${argv0%"$(printf '\nx')"}"
	fi
	readonly argv0

	printf '%s: GNU Bash is required for this script\n' "$argv0" >&2
	exit 1
fi


declare argv0
if [[ ! "$0" =~ ^'/' ]]; then
	argv0="$0"
else
	argv0="$(basename -- "$0" && printf x)"
	argv0="${argv0%$'\nx'}"
fi
readonly argv0


if (($# > 0)); then
	printf '%s: too many arguments: %i\n' "$argv0" $# >&2
	exit 4
fi

# region utils

function command_exists() {
	command -v "$1" > '/dev/null'
}
readonly -f command_exists

function dir_is_empty() {
	local find_out
	find_out="$(find "$tmp_dir_pathname" -mindepth 1 && printf x)"
	find_out="${find_out%x}"
	readonly find_out

	test -z "$find_out"
}
readonly -f dir_is_empty

function remove_empty_dir() {
	if [ -d "$1" ] && dir_is_empty "$1"; then
		rmdir -- "$1"
	fi
}
readonly -f remove_empty_dir

# endregion

declare command_name
for command_name in git sed jq find; do
	if ! command_exists "$command_name"; then
		printf '%s: %s: program missing\n' "$argv0" "$command_name" >&2
		exit 27
	fi
done
unset -v command_name

# region setting up environment variables

if [ -z "${XDG_CONFIG_HOME-}" ]; then
	if [ -z "${HOME-}" ]; then
		printf '%s: HOME environment variable must not be unset or empty\n' "$argv0" >&2
		exit 48
	fi

	if [[ ! "$HOME" =~ ^'/' ]]; then
		printf '%s: %s: HOME environment must be an absolute pathname\n' "$argv0" "$HOME" >&2
		exit 49
	fi

	XDG_CONFIG_HOME="$HOME/.local"
	export XDG_CONFIG_HOME
fi

if [[ ! "$XDG_CONFIG_HOME" =~ ^'/' ]]; then
	printf '%s: %s: XDG_CONFIG_HOME environment must be an absolute pathname\n' "$argv0" "$XDG_CONFIG_HOME" >&2
	exit 49
fi

# endregion

if [ ! -c '/dev/tty' ]; then
	printf '%s: no controlling terminal\n' "$argv0" >&2
	exit 50
fi

# region prompting for target directory

declare target_dir_pathname

printf 'Target directory: ' >&2
while true; do
	read -r target_dir_pathname < '/dev/tty'

	if [ -n "$target_dir_pathname" ]; then
		break
	fi

	printf 'Target directory: (required) ' >&2
done

readonly target_dir_pathname

# endregion

# region cleanup

declare -a _cleanup_expressions
_cleanup_expressions=()

function _do_cleanup() {
	local -i i
	for ((i = (${#_cleanup_expressions[@]} - 1); i >= 0; --i)); do
		eval "${_cleanup_expressions[i]}"
	done
}
readonly -f _do_cleanup

trap _do_cleanup EXIT TERM INT QUIT

function cleanup_push() {
	_cleanup_expressions+=("$1")
}
readonly -f cleanup_push

function cleanup_pop() {
	local -i last_index
	last_index=$((${#_cleanup_expressions[@]} - 1))
	readonly last_index

	if [ "${1-}" = 'execute' ]; then
		eval "${_cleanup_expressions[last_index]}"
	fi

	unset -v _cleanup_expressions\[last_index\]
}
readonly -f cleanup_pop

# endregion

# region setting up temporary directory

declare tmp_dir_pathname
tmp_dir_pathname="${TMPDIR-"${TMP-"/tmp"}"}/mfederczuk_repository_template"
readonly tmp_dir_pathname

function remove_empty_tmp_dir() {
	remove_empty_dir "$tmp_dir_pathname"
}
readonly -f remove_empty_tmp_dir

cleanup_push remove_empty_tmp_dir

if [ ! -e "$tmp_dir_pathname" ]; then
	mkdir -m 777 -- "$tmp_dir_pathname"
fi

# endregion

# region testing for sed -i support

declare sed_i_test_file_pathname
sed_i_test_file_pathname="$tmp_dir_pathname/$RANDOM.txt"

# shellcheck disable=2317
function remove_sed_i_test_file() {
	rm -f -- "$sed_i_test_file_pathname"
}
cleanup_push remove_sed_i_test_file

{
	printf '=== A ===\n'
	printf '=== B ===\n'
	printf '=== C ===\n'
} > "$sed_i_test_file_pathname"

declare sed_i_support
sed_i_support=false
if sed -i -e s/'[AC]'/'(\0)'/g "$sed_i_test_file_pathname" &> '/dev/null'; then
	declare tmp
	tmp="$(< "$sed_i_test_file_pathname")"

	if [ "$tmp" = $'=== (A) ===\n=== B ===\n=== (C) ===' ]; then
		sed_i_support=true
	fi

	unset -v tmp
fi

if ! $sed_i_support; then
	printf '%s: sed does not support option -i\n' "$argv0" >&2
	exit 51
fi

unset -v sed_i_support

cleanup_pop execute
unset -f remove_sed_i_test_file

unset -v sed_i_test_file_pathname

# endregion

# region cloning repository

declare tmp_repo_dir_pathname
tmp_repo_dir_pathname="$tmp_dir_pathname/$RANDOM"
readonly tmp_repo_dir_pathname


function remove_tmp_repo_dir() {
	rm -rf -- "$tmp_repo_dir_pathname"
}
readonly -f remove_tmp_repo_dir

cleanup_push remove_tmp_repo_dir


git clone --quiet --depth=1 -- 'https://github.com/mfederczuk/repository-template.git' "$tmp_repo_dir_pathname"

# endregion

printf '\n' >&2
"$tmp_repo_dir_pathname/use" "$target_dir_pathname" < '/dev/tty'
