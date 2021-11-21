# Copyright (c) 2021 Michael Federczuk
# SPDX-License-Identifier: MPL-2.0 AND Apache-2.0

if [[ "$-" = *'i'* ]]; then
	echo "${BASH_SOURCE[0]}: script was called interactively" >&2
	return 124
fi

declare -i exc=0 exc_tmp || exit

declare tmp_dir_relpath || exit
tmp_dir_relpath="$(mktemp -d)" && {
	readonly tmp_dir_relpath && { (
		set -o errexit

		git clone --depth 1 -- 'https://github.com/mfederczuk/repository-template.git' "$tmp_dir_relpath"
		echo
		{
			read -r -p 'Target directory: ' target_relpath
			"$tmp_dir_relpath/use" "$target_relpath"
		} < '/dev/tty'
	) }
	exc=$?

	rm -rf -- "$tmp_dir_relpath"
	exc_tmp=$?

	if ((exc == 0 && exc_tmp != 0)); then
		exc=$exc_tmp
	fi
}

exit $exc
