#!/bin/bash -e

show-deps () {
	local target="$1"
	make show-${target}-deps
}

packages=$(show-deps $1-$2)
packages=(${packages})
seen=()
while [ ${#packages[@]} -ne 0 ]; do
	p=${packages[0]}
	packages=(${packages[@]/$p})
	[[ "$p" =~ "$1-" ]] || continue
	if ! [[ " ${seen[@]} " =~ " $p " ]]; then
		packages+=($(show-deps $p))
		seen+=($p)
	fi
done
printf '%s\n' "${seen[@]}" | sort

