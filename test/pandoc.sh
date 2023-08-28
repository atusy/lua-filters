#! /bin/bash
if ! git rev-parse --is-inside-git-dir > /dev/null; then
  exit 1
fi

GITDIR=$(git rev-parse --show-toplevel)
cd "${GITDIR}" || exit 1

OUTPUT_FORMAT="${1:-json}"; shift
OUTPUT_EXT="${1:-${OUTPUT_FORMAT}}"; shift

find test -name '*.md' | while read -r md; do
  lua_filter=$(echo "$md" | sed s/^test/lua/ | sed s/md$/lua/)
  if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    pandoc "$md" -t "$OUTPUT_FORMAT" -L "$lua_filter" "$@" | jq -c 'del(.["pandoc-api-version"])' > "${md%md}${OUTPUT_EXT}"
  else
    pandoc "$md" -t "$OUTPUT_FORMAT" -L "$lua_filter" -o "${md%md}${OUTPUT_EXT}" "$@"
  fi
done
