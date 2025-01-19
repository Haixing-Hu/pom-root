#!/bin/bash

################################################################################
#
# 统计git代码库中某个作者的工作量
#
# 作者： 胡海星
#
################################################################################

if (( $# < 1 )); then
  echo "Usage: $0 <project> [author]"
  exit -1;
fi
PROJECT_PATH="$1";

CURRENT_DIR=$(pwd);
# resolve links - $0 may be a softlink
THIS="$0";
while [ -h "$THIS" ]; do
  ls=$(ls -ld "$THIS");
  link=$(expr "$ls" : '.*-> \(.*\)$');
  if expr "$link" : '.*/.*' > /dev/null; then
    THIS="$link"
  else
    THIS=$(dirname "$THIS")/"$link";
  fi
done
THIS_DIR=$(dirname "$THIS");
cd "${THIS_DIR}";
THIS_DIR=$(pwd);
cd "${THIS_DIR}/../../..";
PROJECT_HOME=$(pwd);

# go to the project directory
cd "${PROJECT_HOME}/${PROJECT_PATH}"

# stats for the current user
if (( $# < 2 )); then
  AUTHOR=$(git config --get user.name);
else
  AUTHOR="$2";
fi

echo "Statistics for the author: ${AUTHOR}";
git log --author="${AUTHOR}" --oneline | wc -l \
  | gawk '{ commit = $1; } END { printf "Total commit:    %s\n", commit }';
git log --author="${AUTHOR}" --pretty=tformat: --numstat \
  | gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "Added lines:     %s\nRemoved lines:   %s\nTotal lines:     %s\n",add,subs,loc }'

# return to the current directory
cd "${CURRENT_DIR}";