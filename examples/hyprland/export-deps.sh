#!/usr/bin/bash

set -euxo pipefail

[[ $# -ne 2 ]] && {
    cat >&2 <<'EOF'
ERROR: Required arguments: '$1' (package) and '$2' (out.tar)
EOF
    exit 1
}

package="$1"
out_tar="$2"

# shellcheck disable=SC2207
files=($(pacman -Qlq "${package}"))
files_deps=()
for file in "${files[@]}"; do
    [[ -f $file && $file =~ ^\/usr ]] && files_deps+=("$file")
done

tar -cvf "${out_tar}" "${files_deps[@]}"