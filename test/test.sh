#! /bin/bash

stashed=$(git stash)
SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd $SCRIPT_DIR
cd ..

function postprocess() {
  git reset --hard --quiet
  if [ "$stashed" != "No local changes to save" ]
  then
    git stash pop --quiet
  fi;
}

bash test/pandoc.sh native

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
