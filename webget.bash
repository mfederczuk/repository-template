# Script to clone the repository and copy the template.
# Copyright (C) 2021  Michael Federczuk
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
