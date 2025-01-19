#!/bin/bash

################################################################################
#
#  The script to pull the changes of all projects.
#
#  Author: Haixing Hu (starfish.hu@gmail.com)
#
################################################################################

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

echo "";
echo "-----------------------------------------------------";
echo "";
PROJECT_LIST_FILE="${THIS_DIR}/project-list.txt";

for project in $(cat ${PROJECT_LIST_FILE}); do
        project_dir="${PROJECT_HOME}/${project}";
        if [ -d "${project_dir}" ]; then
            echo "Pulling ${project_dir} ...";
            cd "${project_dir}";
            git lfs pull;
            echo "";
            echo "-----------------------------------------------------";
			echo "";
        fi
done
cd "${CURRENT_DIR}";
