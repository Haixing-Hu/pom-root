#!/bin/bash

################################################################################
#
#  The script to build all projects.
#
#  Author: Haixing Hu (starfish.hu@gmail.com)
#
################################################################################

if (( $# < 1 )); then
    echo "USAGE: ${0} project_module_list_file";
    exit -1;
fi

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
PROJECT_HOME="$(pwd)";
PROJECT_FILE="${1}";

MODULE_LIST_FILE="${THIS_DIR}/${PROJECT_FILE}";
if [ ! -f ${MODULE_LIST_FILE} ]; then
    echo "The building list file '${MODULE_LIST_FILE}' does not exists.";
    exit -1;
fi

LOG_DIR="${PROJECT_HOME}/log";
if [ ! -d "${LOG_DIR}" ]; then
	mkdir -p "${LOG_DIR}";
fi

echo "";
echo "-----------------------------------------------------";
echo "";
for module in $(cat ${MODULE_LIST_FILE}); do
    module_name=$(basename "${module}");
    module_dir="${PROJECT_HOME}/${module}";
    if [ -f "${module_dir}/pom.xml" ]; then
        cd "${module_dir}";
        LOG_FILE="${LOG_DIR}/${module_name}.mvn-install.log";
        echo "Updating ${module} ...";
        git pull;
        echo "Building ${module} ...";
        if mvn clean install &> "${LOG_FILE}"; then
            echo "Build ${module} successfully.";
        else
            echo "Build ${module} failed.";
            echo "Please check the log file ${LOG_FILE} for details."
            exit -1;
        fi
    else
        echo "The ${module_dir}/pom.xml does not exit. Skip it.";
    fi
    echo "";
    echo "-----------------------------------------------------";
    echo "";
done
cd "${CURRENT_DIR}";
