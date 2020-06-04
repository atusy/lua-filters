#! /bin/sh

stashed=$(git stash)

function postprocess() {
  git reset --hard --quiet
  if [ "$stashed" != "No local changes to save" ]
  then
    git stash pop --quiet
  fi;
}

markdowns=$(find test/*.md)
for md in $markdowns
do
  hs=$(echo $md | sed s/md$/hs/)
  lua_filter=$(echo $md | sed s/^test/lua/ | sed s/md$/lua/)
  pandoc $md -t native -o $hs
done

git_diff=$(git diff)

if [ "$git_diff" = "" ]
then
  postprocess
  exit 0
else
  echo "$git_diff"
  postprocess
  exit 1
fi;
