#! /bin/bash

stashed=$(git stash)

if ! git rev-parse --is-inside-git-dir > /dev/null; then
  exit 1
fi

GITDIR=$(git rev-parse --show-toplevel)
cd "${GITDIR}" || exit 1

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
