#!/bin/bash

################################################################################
#
#  The script to clone all projects.
#
#  Author: Haixing Hu (starfish.hu@gmail.com)
#
################################################################################

GIT_URL_PREFIX="ssh://git@dev.njzhyl.cn:10022/njzhyl/";
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
LOG_DIR="${PROJECT_HOME}/log";
if [ ! -d "${LOG_DIR}" ]; then
	mkdir -p "${LOG_DIR}";
fi

echo "";
echo "-----------------------------------------------------";
echo "";
PROJECT_LIST_FILE="${THIS_DIR}/project-list.txt";
for project in $(cat ${PROJECT_LIST_FILE}); do
    project_name=$(basename "${project}");
    project_dir="${PROJECT_HOME}/${project}";
    if [ ! -d "${project_dir}" ]; then
		LOG_FILE="${LOG_DIR}/${project_name}.git-clone.log";
        project_parent=$(dirname "${project_dir}");
        if [ ! -d "${project_parent}" ]; then
            echo "Creating directory ${project_parent} ...";
            if mkdir -p "${project_parent}" &> "${LOG_FILE}"; then
                echo "Successfully create the directory ${project_parent}.";
            else
                echo "Failed to create the directory ${project_parent}. ";
                echo "You may not have the permission.";
                echo "Please check the log file ${LOG_FILE} for details."
            fi
        fi
        echo "Try to clone ${project_dir} ...";
        if git lfs clone "${GIT_URL_PREFIX}${project_name}" "${project}" &> "${LOG_FILE}"; then
            echo "Successfully clone the project ${project}.";
        else
            echo "Failed to clone the project ${project}. ";
            echo "You may not have the permission.";
            echo "Please check the log file ${LOG_FILE} for details."
        fi
        echo "";
        echo "-----------------------------------------------------";
        echo "";
    fi
done
cd "${CURRENT_DIR}";
