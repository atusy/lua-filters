#! /bin/bash
if ! git rev-parse --is-inside-git-dir > /dev/null; then
  exit 1
fi

GITDIR=$(git rev-parse --show-toplevel)
cd "${GITDIR}" || exit 1

if [ "$1" == "" ]
then
  ext="html"
else
  ext="$1"
fi;

find test -name '*.md' | while read -r md; do
  hs="${md%md}hs"
  lua_filter=$(echo "$md" | sed s/^test/lua/ | sed s/md$/lua/)
  pandoc "$md" -L "$lua_filter" -t native -o "$hs"
  if [ "$ext" != "native" ]
  then
    output="${md%md}${ext}"
    pandoc "$md" -L "$lua_filter" -t "$ext" -o "$output" --standalone --metadata title="$md"
  fi;
done