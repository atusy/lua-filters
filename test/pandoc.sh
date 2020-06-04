#! /bin/bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd $SCRIPT_DIR
cd ..
markdowns=$(find test/*.md)

if [ "$1" == "" ]
then
  ext="html"
else
  ext="$1"
fi;

for md in $markdowns
do
  hs=$(echo $md | sed s/md$/hs/)
  lua_filter=$(echo $md | sed s/^test/lua/ | sed s/md$/lua/)
  pandoc $md -L $lua_filter -t native -o $hs
  if [ "$ext" != "native" ]
  then
    output=$(echo $md | sed s/md$/$ext/)
    pandoc $md -L $lua_filter -t $ext -o $output --standalone --metadata title="$md"
  fi;
done