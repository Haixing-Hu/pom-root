#!/bin/bash

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
        if [ ! -d "${project_dir}" ]; then
                echo "Try to clone ${project_dir} ...";
                if git clone git@ascentdimension.dyndns.org:${project}; then
                    echo "Successfully clone the project ${project}.";
                else
                    echo "Failed to clone the project ${project}.";
                fi
        fi
done
cd "${CURRENT_DIR}";
