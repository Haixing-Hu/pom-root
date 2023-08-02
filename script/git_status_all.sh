#!/bin/bash

################################################################################
#
#    Copyright (c) 2022 - 2023.
#    Haixing Hu, Qubit Co. Ltd.
#
#    All rights reserved.
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
cd "${THIS_DIR}/../..";
PROJECT_HOME=$(pwd);

PROJECT_LIST_FILE="${PROJECT_HOME}/pom-root/script/project-list.txt";
for project in $(cat ${PROJECT_LIST_FILE}); do
	project_dir="${PROJECT_HOME}/${project}";
	if [ -d "${project_dir}" ]; then
		echo "Displaying status of ${project_dir} ...";
		cd "${project_dir}";
		git status;
	fi
done
cd "${CURRENT_DIR}";
