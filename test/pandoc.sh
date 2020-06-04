#! /bin/bash
markdowns=$(find test/*.md)
for md in $markdowns
do
  hs=$(echo $md | sed s/md$/hs/)
  lua_filter=$(echo $md | sed s/^test/lua/ | sed s/md$/lua/)
  pandoc $md -L $lua_filter -t native -o $hs
done